resource "yandex_compute_instance" "kibana" {
  hostname = "kibana"
  name = "kibana"
  allow_stopping_for_update = true
  platform_id = "standard-v1"
  zone = "ru-central1-a"

  resources {
    cores = 2
    memory = 8
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
    security_group_ids = [yandex_vpc_security_group.bastion-security-group.id, yandex_vpc_security_group.kibana-security-group.id]
  }

  metadata = {
    user-data = "${file("cloud-config.txt")}"
  }

  depends_on = [yandex_compute_instance.elasticsearch]

  provisioner "local-exec" {
    command = <<EOT
echo "[kibana]" >> hosts.ini;
echo "${self.network_interface.0.ip_address}" >> hosts.ini;
echo "[all]" > all_hosts.ini;
echo "${self.network_interface.0.ip_address}" >> all_hosts.ini;
cat all_vars_hosts.ini >> all_hosts.ini;
echo "---" > vars/kibana.yml;
echo "kibana_server: ${self.network_interface.0.ip_address}" >> vars/kibana.yml;
sleep 30;
ssh-keyscan -H ${self.network_interface.0.ip_address} >> ~/.ssh/known_hosts;
ansible-playbook -i all_hosts.ini tasks/playbook.yml;
EOT
  }
}

output "internal_ip_address_kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.ip_address
}

output "external_ip_address_kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}

