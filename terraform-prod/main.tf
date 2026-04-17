resource "null_resource" "create_vm_prod" {
  provisioner "local-exec" {
    command = <<EOT
      curl -X POST "http://192.168.202.1:8697/api/vms" \
      -u "admin:Terr@1234" \
      -H "Content-Type: application/vnd.vmware.vmw.rest-v1+json" \
      -d '{
        "name": "PROD-AUTOMATISEE",
        "path": "M:/VIRTUAL MACHINE/TERRAFORM/PROD-AUTO.vmx",
        "parentId": "Q6T9SK2QGF02CROM2I2493QOBNMAMMM8"
      }'
    EOT
  }
}

resource "null_resource" "start_vm_prod" {
  depends_on = [null_resource.create_vm_prod]

  provisioner "local-exec" {
    # On attend 5 secondes, puis on allume
    command = "sleep 5 && curl -X PUT http://192.168.202.1:8697/api/vms/PROD-AUTOMATISEE/power -u admin:Terr@1234 -H \"Content-Type: application/vnd.vmware.vmw.rest-v1+json\" -d \"on\""
  }
}
