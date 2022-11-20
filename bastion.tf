resource "yandex_compute_instance" "bastion" {
  hostname = "bastion"
  name = "bastion"
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
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat = true
    security_group_ids = [yandex_vpc_security_group.bastion-security-group.id, yandex_vpc_security_group.elasticsearch-security-group.id]
  }

  metadata = {
    user-data = "${file("cloud-config.txt")}"
  }

  depends_on = [yandex_vpc_security_group.bastion-security-group]

  provisioner "local-exec" {
    command = <<EOT
sleep 50;
echo "---" > vars/bastion.yml;
echo "bastion_server: ${self.network_interface.0.nat_ip_address}" >> vars/bastion.yml;
ssh-keyscan -H ${self.network_interface.0.nat_ip_address} >> ~/.ssh/known_hosts;
echo "Host 192.168.10.*" > ~/.ssh/config;
echo "  User ubuntu" >> ~/.ssh/config;
echo "  StrictHostKeyChecking no" >> ~/.ssh/config;
echo "  ProxyJump ubuntu@${self.network_interface.0.nat_ip_address}" >> ~/.ssh/config;
echo "  IdentityFile ~/.ssh/id_ed25519" >> ~/.ssh/config;
echo "Host 192.168.20.*" >> ~/.ssh/config;
echo "  User ubuntu" >> ~/.ssh/config;
echo "  StrictHostKeyChecking no" >> ~/.ssh/config;
echo "  ProxyJump ubuntu@${self.network_interface.0.nat_ip_address}" >> ~/.ssh/config;
echo "  IdentityFile ~/.ssh/id_ed25519" >> ~/.ssh/config;
echo "Host 192.168.30.*" >> ~/.ssh/config;
echo "  User ubuntu" >> ~/.ssh/config;
echo "  StrictHostKeyChecking no" >> ~/.ssh/config;
echo "  ProxyJump ubuntu@${self.network_interface.0.nat_ip_address}" >> ~/.ssh/config;
echo "  IdentityFile ~/.ssh/id_ed25519" >> ~/.ssh/config;
echo "[elasticsearch:vars]" > hosts.ini;
echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -W %h:%p -q ubuntu@${self.network_interface.0.nat_ip_address}\"'" >> hosts.i>
echo "[web:vars]" >> hosts.ini;
echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -W %h:%p -q ubuntu@${self.network_interface.0.nat_ip_address}\"'" >> hosts.i>
echo "[prometheus:vars]" >> hosts.ini;
echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -W %h:%p -q ubuntu@${self.network_interface.0.nat_ip_address}\"'" >> hosts.i>
echo "[all:vars]" > all_vars_hosts.ini;
echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -W %h:%p -q ubuntu@${self.network_interface.0.nat_ip_address}\"'" >> all_vars_hosts.ini;
EOT
  }
}

output "internal_ip_address_bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.ip_address
}

output "external_ip_address_bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

