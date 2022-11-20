resource "yandex_vpc_subnet" "subnet-1" {
  name = "subnet-1"
  zone = "ru-central1-a"
  network_id = var.network_id
  v4_cidr_blocks = ["192.168.10.0/24"]
  route_table_id = yandex_vpc_route_table.route-table.id
}

resource "yandex_vpc_subnet" "subnet-2" {
  name = "subnet-2"
  zone = "ru-central1-b"
  network_id = var.network_id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.route-table.id
}

resource "yandex_vpc_subnet" "public" {
  name = "public"
  zone = "ru-central1-a"
  network_id = var.network_id
  v4_cidr_blocks = ["192.168.30.0/24"]
  route_table_id = yandex_vpc_route_table.route-table.id
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "route-table" {
  name = "route-table"
  network_id = var.network_id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id = yandex_vpc_gateway.nat_gateway.id
  }
}
