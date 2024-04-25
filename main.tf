#resource group where the whole deployment shall be done
resource "azurerm_resource_group" "rgst" {
  location = var.location
  name     = var.rgname
}

#number of random characters is 3 
#does not contain specia chars neither upper etters
#keepers (Map of String) Arbitrary map of values that, when changed, will trigger recreation of resource. 
#this is the prefix for storage account as it should be globally unique
resource "random_string" "stnamepostfix" {
  length  = 3
  special = false
  upper   = false
  keepers = {
    stname = var.stname
  }
}


#storage account where static web site is going to be hosted
#Hot LRS and StorageV2 - Standard access_tier
#2 files should be defined for site: index.html and 404.html
resource "azurerm_storage_account" "stweb" {
  location                 = azurerm_resource_group.rgst.location
  resource_group_name      = azurerm_resource_group.rgst.name
  name                     = "${var.stname}${random_string.stnamepostfix.result}"
  access_tier              = "Hot"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
 #account_replication_type = "ZRS"
  account_tier             = "Standard"
  #enable_https_traffic_only     = true
  enable_https_traffic_only     = false
  public_network_access_enabled = true

  static_website {
    index_document     = "index.html"
    error_404_document = "404.html"

  }
}

#static web site needs $web container which is automatically created from previous declaration
#does not need another terraform resource so here we are just referring to it
data "azurerm_storage_container" "stcontainer" {
  name                 = "$web"
  storage_account_name = azurerm_storage_account.stweb.name
}


#upload css files in blob
#needs content type
module "stblobcss" {
  source = "./modules/blob"

  rgname          = var.rgname
  stweb_name      = azurerm_storage_account.stweb.name
  stcontainername = data.azurerm_storage_container.stcontainer.name
  inputpath       = "/upload/"
  outputpath      = "css/*"
  contenttype     = "text/css"
}

#upload js files in blob
#needs content type
module "stblobjs" {
  source          = "./modules/blob"
  rgname          = var.rgname
  stweb_name      = azurerm_storage_account.stweb.name
  stcontainername = data.azurerm_storage_container.stcontainer.name

  inputpath   = "/upload/"
  outputpath  = "js/*"
  contenttype = "text/javascript"
}

#upload csv files in blob
#needs content type
module "stblobcsv" {
  source          = "./modules/blob"
  rgname          = var.rgname
  stweb_name      = azurerm_storage_account.stweb.name
  stcontainername = data.azurerm_storage_container.stcontainer.name

  inputpath   = "/upload/"
  outputpath  = "train/*"
  contenttype = "text/csv"
}

#upload html files in blob
#needs content type
module "stblobhtml" {
  source          = "./modules/blob"
  rgname          = var.rgname
  stweb_name      = azurerm_storage_account.stweb.name
  stcontainername = data.azurerm_storage_container.stcontainer.name

  inputpath   = "/"
  outputpath  = "*.html"
  contenttype = "text/html"
}


#upload jpg and png files in blob
#needs content type
resource "azurerm_storage_blob" "stblobimage" {
  for_each               = fileset("${path.root}/upload/", "images/*")
  name                   = each.key
  storage_account_name   = azurerm_storage_account.stweb.name
  storage_container_name = data.azurerm_storage_container.stcontainer.name
  type                   = "Block"
  source                 = "${path.root}/upload/${each.key}"
  content_type           = endswith("$source", ".png") ? "image/png" : "image/jpg"

  depends_on = [
    azurerm_storage_account.stweb
  ]
  #condition to check before apply that it is the correct container where files are uploaded
  #show how precondition Block is used
  #contract test
  lifecycle {
    precondition {
      condition     = data.azurerm_storage_container.stcontainer.name == "$web"
      error_message = "Expected containername $web as it is required by static website"
    }
  }
}

#create cdn profile for performance and security
resource "azurerm_cdn_profile" "cdnprofile" {
  name                = "mystcdnprofile"
  location            = azurerm_resource_group.rgst.location
  resource_group_name = azurerm_resource_group.rgst.name
  sku                 = "Standard_Microsoft"
}

#cdn endpoint points to storage account container web endpoint : static web site"
resource "azurerm_cdn_endpoint" "cdnep" {
  name                          = "myilicdnep"
  profile_name                  = azurerm_cdn_profile.cdnprofile.name
  location                      = azurerm_resource_group.rgst.location
  resource_group_name           = azurerm_resource_group.rgst.name
  is_http_allowed               = true
  is_https_allowed              = true
  querystring_caching_behaviour = "IgnoreQueryString"
  is_compression_enabled        = true
  content_types_to_compress = [
    "application/eot",
    "application/font",
    "application/font-sfnt",
    "application/javascript",
    "application/json",
    "application/opentype",
    "application/otf",
    "application/pkcs7-mime",
    "application/truetype",
    "application/ttf",
    "application/vnd.ms-fontobject",
    "application/xhtml+xml",
    "application/xml",
    "application/xml+rss",
    "application/x-font-opentype",
    "application/x-font-truetype",
    "application/x-font-ttf",
    "application/x-httpd-cgi",
    "application/x-javascript",
    "application/x-mpegurl",
    "application/x-opentype",
    "application/x-otf",
    "application/x-perl",
    "application/x-ttf",
    "font/eot",
    "font/ttf",
    "font/otf",
    "font/opentype",
    "image/svg+xml",
    "text/css",
    "text/csv",
    "text/html",
    "text/javascript",
    "text/js",
    "text/plain",
    "text/richtext",
    "text/tab-separated-values",
    "text/xml",
    "text/x-script",
    "text/x-component",
    "text/x-java-source"
  ]
   origin_host_header = azurerm_storage_account.stweb.primary_web_host

  origin {
    name = "myorigin"
    host_name = azurerm_storage_account.stweb.primary_web_host
   
  }


  depends_on = [
    azurerm_storage_account.stweb,
    azurerm_cdn_profile.cdnprofile
  ]
}

#from this check Block we can check after apply that site is up
#terraform http provider downloaded
#end to end test
check "site_health_check" {

  data "http" "myurl" {
    url = "https://${azurerm_storage_account.stweb.primary_web_host}"
  }
  
  assert {
    condition = data.http.myurl.status_code == 200
    error_message = "${data.http.myurl.url} returned an unhealthy status code"
  }
  
}


