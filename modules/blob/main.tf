
resource "azurerm_storage_blob" "stblobmod" {
  for_each               = fileset("${path.root}${var.inputpath}", "${var.outputpath}")
  name                   = each.key
  storage_account_name   = var.stweb_name
  storage_container_name = var.stcontainername
  type                   = "Block"
  content_type           = var.contenttype
  source                 = "${path.root}${var.inputpath}${each.key}"


}