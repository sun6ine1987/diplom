resource "yandex_compute_instance" "nginx-1" {
  hostname = "nginx-1"
  name = "nginx-1"
  allow_stopping_for_update = true
  platform_id = "standard-v1"
  zone = "ru-central1-a"

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.yandex_image_id
      size = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    security_group_ids = [yandex_vpc_security_group.bastion-security-group.id, yandex_vpc_security_group.nginx-security-group.id]
  }

  metadata = {
    user-data = "${file("cloud-config.txt")}"
  }

  depends_on = [yandex_compute_instance.kibana]

  provisioner "local-exec" {
    command = <<EOT
echo "[web]" >> hosts.ini;
echo "${self.network_interface.0.ip_address}" >> hosts.ini;
echo "[all]" > all_hosts.ini;
echo "${self.network_interface.0.ip_address}" >> all_hosts.ini;
cat all_vars_hosts.ini >> all_hosts.ini;
echo "---" > vars/nginx.yml;
echo "web_servers:" >> vars/nginx.yml;
echo "  - ${self.network_interface.0.ip_address}" >> vars/nginx.yml;
sleep 30;
ssh-keyscan -H ${self.network_interface.0.ip_address} >> ~/.ssh/known_hosts;
ansible-playbook -i all_hosts.ini tasks/playbook.yml;
EOT
  }

}

resource "yandex_compute_instance" "nginx-2" {
  hostname = "nginx-2"
  name = "nginx-2"
  allow_stopping_for_update = true
  platform_id = "standard-v1"
  zone = "ru-central1-b"

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.yandex_image_id
      size = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-2.id
    security_group_ids = [yandex_vpc_security_group.bastion-security-group.id, yandex_vpc_security_group.nginx-security-group.id]
  }

  metadata = {
    user-data = "${file("cloud-config.txt")}"
  }

  depends_on = [yandex_compute_instance.nginx-1]

  provisioner "local-exec" {
    command = <<EOT
echo "${self.network_interface.0.ip_address}" >> hosts.ini;
echo "[all]" > all_hosts.ini;
echo "${self.network_interface.0.ip_address}" >> all_hosts.ini;
cat all_vars_hosts.ini >> all_hosts.ini;
echo "  - ${self.network_interface.0.ip_address}" >> vars/nginx.yml;
sleep 30;
ssh-keyscan -H ${self.network_interface.0.ip_address} >> ~/.ssh/known_hosts;
ansible-playbook -i all_hosts.ini tasks/playbook.yml;
EOT
  }
}

output "internal_ip_address_nginx-1" {
  value = yandex_compute_instance.nginx-1.network_interface.0.ip_address
}

output "external_ip_address_nginx-1" {
  value = yandex_compute_instance.nginx-1.network_interface.0.nat_ip_address
}

output "internal_ip_address_nginx-2" {
  value = yandex_compute_instance.nginx-2.network_interface.0.ip_address
}

output "external_ip_address_nginx-2" {
  value = yandex_compute_instance.nginx-2.network_interface.0.nat_ip_address
}

