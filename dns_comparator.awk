{
  if (FNR == 1) {
    print "### Processing: "FILENAME
  }
  authoritive_nameserver = ARGV["authoritive_name_server"]
  if ($1 == "$ORIGIN") {
    origin = $2
  }
  if ($3 == "PTR") {
    record_type = "PTR"
    record = $1"."origin
  }
  else {
    record_type = $4
    record = $1
  }
  if ((record_type == "A") || (record_type == "TXT") || (record_type == "CNAME") || (record_type == "PTR")) {
    record_value = $0
    delete dig_response
    dig_response_line = ""
    switch (NF) {
    case 4:
      sub(/^[[:blank:]]*([[:graph:]]+[[:blank:]]+){3}/, "", record_value)
      break
    default:
      sub(/^[[:blank:]]*([[:graph:]]+[[:blank:]]+){4}/, "", record_value)
      break
    }
    cmd = "dig @"authoritive_nameserver" +short "record" "record_type
    while (cmd | getline dig_response_line) {
      dig_response[dig_response_line] = "found"
    }
    close(cmd)
    if (dig_response[record_value] =! "found" ) {
      print "Bad match: "record" "record_type
      print "  command:   '"cmd"'"
      print "  dyn:       '"dig_response"'"
      print "  zone_file: '"record_value"'\n"
    }
  }
}
