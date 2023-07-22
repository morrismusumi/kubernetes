# Node IPs
output "kube-node-1-ip" {
  value = [for node in hcloud_server.kube-node[0].network: node.ip]
}

output "kube-node-2-ip" {
  value = [for node in hcloud_server.kube-node[1].network: node.ip]
}

output "kube-node-3-ip" {
  value = [for node in hcloud_server.kube-node[2].network: node.ip]
}

