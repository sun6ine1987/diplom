resource "yandex_alb_target_group" "nginx-target-group" {
  name = "nginx-target-group"

  target {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    ip_address = yandex_compute_instance.nginx-1.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet-2.id
    ip_address = yandex_compute_instance.nginx-2.network_interface.0.ip_address
  }

  depends_on = [yandex_compute_instance.nginx-2]
}

resource "yandex_alb_backend_group" "nginx-backend-group" {
  name = "nginx-backend-group"

  http_backend {
    name = "nginx-http-backend"
    weight = 1
    port = 80
    target_group_ids = [yandex_alb_target_group.nginx-target-group.id]
    load_balancing_config {
      panic_threshold = 90
    }
    healthcheck {
      timeout = "10s"
      interval = "2s"
      healthy_threshold = 10
      unhealthy_threshold = 15
      http_healthcheck {
        path = "/"
      }
    }
  }
  depends_on = [yandex_alb_target_group.nginx-target-group]
}

resource "yandex_alb_http_router" "nginx-router" {
  name = "nginx-router"
  labels = {
    tf-label = "nginx-router"
    empty-label = ""
  }

  depends_on = [yandex_compute_instance.nginx-2]
}

resource "yandex_alb_virtual_host" "nginx-virtual-host" {
  name = "nginx-virtual-host"
  http_router_id = yandex_alb_http_router.nginx-router.id
  route {
    name = "nginx-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.nginx-backend-group.id
        timeout = "3s"
      }
    }
  }
  depends_on = [yandex_alb_http_router.nginx-router, yandex_alb_backend_group.nginx-backend-group]
}

resource "yandex_alb_load_balancer" "nginx-balancer" {
  name = "nginx-balancer"
  network_id = var.network_id

  allocation_policy {
    location {
      zone_id = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-1.id
    }

    location {
      zone_id = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnet-2.id
    }
  }

  listener {
    name = "listener-nginx"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.nginx-router.id
      }
    }
  }

  depends_on = [yandex_alb_http_router.nginx-router]
}

