json.draw params[:draw].to_i
json.recordsTotal @report.records_total
json.recordsFiltered @report.records_total

json.data @report.data_to_hash

json.total @report.total_to_hash
