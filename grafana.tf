resource "yandex_compute_instance" "grafana" {
  hostname = "grafana"
  name = "grafana"
  allow_stopping_for_update = true
  platform_id = "standard-v1"
  zone = "ru-central1-a"

  resources {
    cores = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.yandex_image_id
      size = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat = true
    security_group_ids = [yandex_vpc_security_group.bastion-security-group.id, yandex_vpc_security_group.grafana-security-group.id]
  }

  metadata = {
    user-data = "${file("cloud-config.txt")}"
  }

  depends_on = [yandex_compute_instance.prometheus]

  provisioner "local-exec" {
    command = <<EOT
echo "[grafana]" >> hosts.ini;
echo "${self.network_interface.0.ip_address}" >> hosts.ini;
echo "[all]" > all_hosts.ini;
echo "${self.network_interface.0.ip_address}" >> all_hosts.ini;
cat all_vars_hosts.ini >> all_hosts.ini;
sleep 30;
ssh-keyscan -H ${self.network_interface.0.ip_address} >> ~/.ssh/known_hosts;
ansible-playbook -i all_hosts.ini tasks/playbook.yml;
EOT
  }
}

output "internal_ip_address_grafana" {
  value = yandex_compute_instance.grafana.network_interface.0.ip_address
}

output "external_ip_address_grafana" {
  value = yandex_compute_instance.grafana.network_interface.0.nat_ip_address
}

