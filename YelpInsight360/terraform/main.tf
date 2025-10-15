terraform {
  required_version = ">= 1.0"
  backend "local" {}
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.55.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  // credentials = file(var.credentials)  # Use this if you do not want to set env-var GOOGLE_APPLICATION_CREDENTIALS
}

module "apis" {
  source = "./modules/apis"
}

module "storage" {
  source = "./modules/storage"

  datalake_name                              = var.datalake_name
  datalake_region                            = var.datalake_region
  datalake_storage_class                     = var.datalake_storage_class
  datalake_uniform_bucket_level_access       = var.datalake_uniform_bucket_level_access
  datalake_public_access_prevention          = var.datalake_public_access_prevention
  datalake_lifecycle_rule_action             = var.datalake_lifecycle_rule_action
  datalake_lifecycle_rule_condition_age_days = var.datalake_lifecycle_rule_condition_age_days
  datalake_force_destroy                     = var.datalake_force_destroy

  ingest_business_data_script_path = var.ingest_business_data_script_path
  ingest_checkin_data_script_path  = var.ingest_checkin_data_script_path
  ingest_reviews_data_script_path  = var.ingest_reviews_data_script_path
  ingest_tips_data_script_path     = var.ingest_tips_data_script_path
  ingest_users_data_script_path    = var.ingest_users_data_script_path

  depends_on = [
    module.apis
  ]
}

module "bigquery" {
  source = "./modules/bigquery"

  project_id = var.project_id

  // staging dataset config
  bigquery_staging_dataset_name                       = var.bigquery_staging_dataset_name
  bigquery_staging_dataset_description                = var.bigquery_staging_dataset_description
  bigquery_staging_dataset_region                     = var.bigquery_staging_dataset_region
  bigquery_staging_dataset_delete_contents_on_destroy = var.bigquery_staging_dataset_delete_contents_on_destroy

  // dbt dataset config
  bigquery_dbt_dataset_name                       = var.bigquery_dbt_dataset_name
  bigquery_dbt_dataset_description                = var.bigquery_dbt_dataset_description
  bigquery_dbt_dataset_region                     = var.bigquery_dbt_dataset_region
  bigquery_dbt_dataset_delete_contents_on_destroy = var.bigquery_dbt_dataset_delete_contents_on_destroy

  // business staging table config
  bigquery_staging_business_table_name                = var.bigquery_staging_business_table_name
  bigquery_staging_business_table_description         = var.bigquery_staging_business_table_description
  bigquery_staging_business_table_deletion_protection = var.bigquery_staging_business_table_deletion_protection
  bigquery_staging_business_table_schema_filepath     = var.bigquery_staging_business_table_schema_filepath
  bigquery_staging_business_table_partition_column    = var.bigquery_staging_business_table_partition_column

  // checkins staging table config
  bigquery_staging_checkin_table_name                = var.bigquery_staging_checkin_table_name
  bigquery_staging_checkin_table_description         = var.bigquery_staging_checkin_table_description
  bigquery_staging_checkin_table_deletion_protection = var.bigquery_staging_checkin_table_deletion_protection
  bigquery_staging_checkin_table_schema_filepath     = var.bigquery_staging_checkin_table_schema_filepath

  // reviews staging table config
  bigquery_staging_reviews_table_name                = var.bigquery_staging_reviews_table_name
  bigquery_staging_reviews_table_description         = var.bigquery_staging_reviews_table_description
  bigquery_staging_reviews_table_deletion_protection = var.bigquery_staging_reviews_table_deletion_protection
  bigquery_staging_reviews_table_schema_filepath     = var.bigquery_staging_reviews_table_schema_filepath

  // tips staging table config
  bigquery_staging_tips_table_name                = var.bigquery_staging_tips_table_name
  bigquery_staging_tips_table_description         = var.bigquery_staging_tips_table_description
  bigquery_staging_tips_table_deletion_protection = var.bigquery_staging_tips_table_deletion_protection
  bigquery_staging_tips_table_schema_filepath     = var.bigquery_staging_tips_table_schema_filepath

  // users staging table config
  bigquery_staging_users_table_name                = var.bigquery_staging_users_table_name
  bigquery_staging_users_table_description         = var.bigquery_staging_users_table_description
  bigquery_staging_users_table_deletion_protection = var.bigquery_staging_users_table_deletion_protection
  bigquery_staging_users_table_schema_filepath     = var.bigquery_staging_users_table_schema_filepath

  depends_on = [
    module.apis
  ]
}

module "dataproc" {
  source = "./modules/dataproc"

  // Cluster Config
  dataproc_cluster_name                  = var.dataproc_cluster_name
  dataproc_cluster_region                = var.dataproc_cluster_region
  dataproc_graceful_decommission_timeout = var.dataproc_graceful_decommission_timeout
  dataproc_master_num_instances          = var.dataproc_master_num_instances
  dataproc_master_machine_type           = var.dataproc_master_machine_type
  dataproc_master_boot_disk_type         = var.dataproc_master_boot_disk_type
  dataproc_master_boot_disk_size_gb      = var.dataproc_master_boot_disk_size_gb
  dataproc_worker_num_instances          = var.dataproc_worker_num_instances
  dataproc_worker_machine_type           = var.dataproc_worker_machine_type
  dataproc_worker_boot_disk_type         = var.dataproc_worker_boot_disk_type
  dataproc_worker_boot_disk_size_gb      = var.dataproc_worker_boot_disk_size_gb
  dataproc_image_version                 = var.dataproc_image_version
  dataproc_allow_zero_workers            = var.dataproc_allow_zero_workers

  // Staging bucket config
  dataproc_staging_bucket_name                              = var.dataproc_staging_bucket_name
  dataproc_staging_bucket_region                            = var.dataproc_staging_bucket_region
  dataproc_staging_bucket_storage_class                     = var.dataproc_staging_bucket_storage_class
  dataproc_staging_bucket_uniform_bucket_level_access       = var.dataproc_staging_bucket_uniform_bucket_level_access
  dataproc_staging_bucket_public_access_prevention          = var.dataproc_staging_bucket_public_access_prevention
  dataproc_staging_bucket_lifecycle_rule_action             = var.dataproc_staging_bucket_lifecycle_rule_action
  dataproc_staging_bucket_lifecycle_rule_condition_age_days = var.dataproc_staging_bucket_lifecycle_rule_condition_age_days
  dataproc_staging_bucket_force_destroy                     = var.dataproc_staging_bucket_force_destroy

  // Temp bucket config
  dataproc_temp_bucket_name                              = var.dataproc_temp_bucket_name
  dataproc_temp_bucket_region                            = var.dataproc_temp_bucket_region
  dataproc_temp_bucket_storage_class                     = var.dataproc_temp_bucket_storage_class
  dataproc_temp_bucket_uniform_bucket_level_access       = var.dataproc_temp_bucket_uniform_bucket_level_access
  dataproc_temp_bucket_public_access_prevention          = var.dataproc_temp_bucket_public_access_prevention
  dataproc_temp_bucket_lifecycle_rule_action             = var.dataproc_temp_bucket_lifecycle_rule_action
  dataproc_temp_bucket_lifecycle_rule_condition_age_days = var.dataproc_temp_bucket_lifecycle_rule_condition_age_days
  dataproc_temp_bucket_force_destroy                     = var.dataproc_temp_bucket_force_destroy

  depends_on = [
    module.apis
  ]
}

module "composer" {
  source = "./modules/composer"

  // environment config
  project_id                     = var.project_id
  composer_env_name              = var.composer_env_name
  composer_region                = var.composer_region
  compose_image_version          = var.compose_image_version
  composer_service_account_email = var.composer_service_account_email
  composer_environment_size      = var.composer_environment_size
  dags_file_path                 = var.dags_file_path

  // scheduler config
  scheduler_cpu        = var.scheduler_cpu
  scheduler_memory_gb  = var.scheduler_memory_gb
  scheduler_storage_gb = var.scheduler_memory_gb
  scheduler_count      = var.scheduler_count

  // web server config
  webserver_cpu        = var.webserver_cpu
  webserver_memory_gb  = var.webserver_memory_gb
  webserver_storage_gb = var.webserver_storage_gb

  // worker config
  worker_cpu        = var.worker_cpu
  worker_memory_gb  = var.worker_memory_gb
  worker_storage_gb = var.worker_storage_gb
  worker_min_count  = var.worker_min_count
  worker_max_count  = var.worker_max_count

  depends_on = [
    module.apis
  ]
}