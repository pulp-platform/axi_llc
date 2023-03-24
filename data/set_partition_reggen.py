# This file is used to automatecally generate the set-based partition 
# configuration registers into 'set_partition_reggen.hjson'. Also it 
# calculates the jump value for 'COMMIT_PARTITION_CFG' and 'FLUSHED_LOW',
# of which the address is not continuous compared to the previous register

num_parreg = 4

with open('set_partition_reggen.hjson', 'w') as f:
    for i in range(num_parreg):
        f.write(f'''{{ name: "CFG_SET_PARTITION{i}_LOW",
   desc: "Index-based Partition Configuration [31:0] (lower 32 bit)",
   swaccess: "rw",
   hwaccess: "hrw",
   fields: [
    {{bits: "31:0", name: "low", desc: "lower 32 bit"}}
   ]
}},
{{ name: "CFG_SET_PARTITION{i}_HIGH",
   desc: "Index-based Partition Configuration [63:32] (upper 32 bit)",
   swaccess: "rw",
   hwaccess: "hrw",
   fields: [
    {{bits: "31:0", name: "high", desc: "upper 32 bit"}}
   ]
}},''')

    f.write(f'''
{{ name: "COMMIT_CFG",
  desc: "Commit the configuration",
  swaccess: "rw1s",
  hwaccess: "hrw",
  fields: [
    {{bits: "0", name: "commit", desc: "commit configuration"}}
  ]
}},
{{skipto: "{hex(0x30 + (num_parreg + 1) * 0x08)}"}}
{{ name: "COMMIT_PARTITION_CFG",
  desc: "Commit the set partition configuration",
  swaccess: "rw1s",
  hwaccess: "hrw",
  fields: [
    {{bits: "0", name: "commit", desc: "commit set partition configuration"}}
  ]
}},
{{skipto: "{hex(0x30 + (num_parreg + 2) * 0x08)}"}}''')

print('Successfully generate the reggen content related to set-based partition configuration registers in "set_partition_reggen.hjson"!')