# --------------------------Basic-------------------------------------------

variable "resource_group_name" {}
variable "resource_group_location" {
  default = "west europe"
}
variable "environmentName" {}
variable "location" {
  default = "West Europe"
}
variable "tags" {
  type = map(string)
  default = {
    "createdBy" = "Devops"
  }
}

# --------------------------APIM------------------------------------------
variable "apim" {
  type = map(string)
  default = {
    apim_sku = "developer"
  }
}
variable "apim_publisher" {
  type = map(string)
  default = {
    name  = "kpmgCO-MVP"
    email = "r.garg.c@kpmgco.com"
  }
}

variable "fnKeys" {
  default = "dummy"
}


# ------------------------Storage Account---------------------------------
variable "storage_account_tier" {
  default = "Standard"

}
variable "storage_account_type" {
  default = "LRS"
} 

# --------------------------MSSQL--------------------------------------
variable "password_policy" {
  type = map(string)
  default = {
    length  = 17
    special = false
  }
}

# -------------------------Function App-----------------------------------
variable "function_sku" {
  type = map(string)
  default = {
    tier = "Standard"
    size = "S1"
  }
}

variable "function_sku1" {
  type = map(string)
  default = {
    tier = "Standard"
    size = "S1"
  }
}
variable "function_kind" {
  default = "Windows"
}
variable "fn_location" {
  default = "West Europe"
}

#-------------------------------------------------------------

variable "enable_sql_server_extended_auditing_policy" {
  default     = true
}

variable "enable_database_extended_auditing_policy" {
  default     = true
}

variable "enable_threat_detection_policy" {
  default     = false

}

variable "fnreserved" {
  default     = false

}

variable "fehost" {
  default     = "false.com"

}

variable "pfxfile" {
  default = ""
}

variable "pfxpwd" {
  default = ""
}


variable "hubspotapikey" {
  default = ""
}

variable "hubspotclientsecret" {
  default = ""
}


variable "publickeyencryption" {
      default = ""
    
 }

 variable "serverprivatekey" {
      default = ""
    
 }

 variable "sentryauthtoken" {
      default = ""
    
 }

  variable "gaid" {
      default = ""
    
 }