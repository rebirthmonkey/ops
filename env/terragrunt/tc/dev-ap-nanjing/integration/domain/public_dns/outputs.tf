output "records" {
  value = {for k, record in local.records: format("%s.%s", record.sub_domain, local.domain) => format("%s %s", record.record_type, record.value)}
}