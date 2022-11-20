resource "yandex_vpc_security_group" "bastion-security-group" {
  name        = "bastion-security-group"
  network_id  = var.network_id

  ingress {
    protocol  = "TCP"
    description    = "Rule ingress port 22"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port  = 22
  }
  ingress {
    protocol = "TCP"
    predefined_target = "self_security_group"
    port = 22
  }
   egress {
    protocol = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "nginx-security-group" {
  name        = "nginx-security-group"
  network_id  = var.network_id

  ingress {
    protocol  = "TCP"
    description    = "Rule ingress port 80"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port  = 80
  }
  egress {
    protocol = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "yandex_vpc_security_group" "elasticsearch-security-group" {
  name        = "elasticsearch-security-group"
  network_id  = var.network_id

  ingress {
    protocol  = "TCP"
    description    = "Rule ingress port 9200"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port  = 9200
  }
  ingress {
    protocol  = "TCP"
    description    = "Rule ingress port 5044"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port  = 5044
  }
   egress {
    protocol = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "kibana-security-group" {
  name        = "kibana-security-group"
  network_id  = var.network_id

  ingress {
    protocol  = "TCP"
    description    = "Rule ingress port 5601"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port  = 5601
  }
  egress {
    protocol = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "prometheus-security-group" {
  name        = "prometheus-security-group"
  network_id  = var.network_id

  ingress {
    protocol  = "TCP"
    description    = "Rule ingress port 9090"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port  = 9090
  }
  egress {
    protocol = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "grafana-security-group" {
  name        = "grafana-security-group"
  network_id  = var.network_id

  ingress {
    protocol  = "TCP"
    description    = "Rule ingress port 3000"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port  = 3000
  }
  egress {
    protocol = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

