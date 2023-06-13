# This file is used to automatecally generate 'set_partition_reggen.hjson'

import math
import sys
# all variables below are just for verification
RegWidth    = int(sys.argv[1]) # 64 Same as "RegWidth" in sv
NumLines    = int(sys.argv[2]) # 256 Same as "Sfg.NumLines in sv
MaxThread   = int(sys.argv[3]) # 256 Same as "MaxThread" in sv
CachePartition = int(sys.argv[4]) # Signals whether cache partitioning is enabled or disabled, 1 means "enable"
IndexLength = math.ceil(math.log2(NumLines))  # Same as "Cfg.IndexLength" in sv
num_setflushreg = math.ceil(NumLines / RegWidth)
num_parreg  = math.ceil(MaxThread / math.floor(RegWidth / IndexLength))  # The number of configuration registers used for set partitioning.
valid_reg_bit = math.floor(RegWidth / IndexLength) * IndexLength
reg_before_commit = 4

with open('data/axi_llc_regs.hjson', 'w') as f:
    f.write('// Copyright 2018-2021 ETH Zurich and University of Bologna.\n\
// Solderpad Hardware License, Version 0.51, see LICENSE for details.\n\
// SPDX-License-Identifier: SHL-0.51\n\
//\n\
// Authors: \n\
// Nicole Narr <narrn@ethz.ch>\n\
// Christopher Reinwardt <creinwar@ethz.ch>\n\
\n\
\n\
\n\
{\n\
  name: "axi_llc",\n\
  clock_primary: "clk_i",\n\
  bus_interfaces: [\n\
    { protocol: "reg_iface", direction: "device" }\n\
  ],\n\
  regwidth: 32,\n\
  registers: [\n\
\n\
    { name: "CFG_SPM_LOW",\n\
      desc: "SPM Configuration (lower 32 bit)",\n\
      swaccess: "rw",\n\
      hwaccess: "hrw",\n\
      fields: [\n\
        {bits: "31:0", resval: 0, name: "low", desc: "lower 32 bit"}\n\
      ]\n\
    },\n\
    { name: "CFG_SPM_HIGH",\n\
      desc: "SPM Configuration (upper 32 bit)",\n\
      swaccess: "rw",\n\
      hwaccess: "hrw",\n\
      fields: [\n\
        {bits: "31:0", name: "high", desc: "upper 32 bit"}\n\
      ]\n\
    },\n\
    { name: "CFG_FLUSH_LOW",\n\
      desc: "Flush Configuration (lower 32 bit)",\n\
      swaccess: "rw",\n\
      hwaccess: "hrw",\n\
      fields: [\n\
        {bits: "31:0", name: "low", desc: "lower 32 bit"}\n\
      ]\n\
    },\n\
    { name: "CFG_FLUSH_HIGH",\n\
      desc: "Flush Configuration (upper 32 bit)",\n\
      swaccess: "rw",\n\
      hwaccess: "hrw",\n\
      fields: [\n\
        {bits: "31:0", name: "high", desc: "upper 32 bit"}\n\
      ]\n\
    },')
    if CachePartition != 0: 
      f.write('\n\
    { name: "CFG_FLUSH_THREAD_LOW",\n\
      desc: "Index-based Thread Flush Configuration [31:0] (lower 32 bit)",\n\
      swaccess: "rw",\n\
      hwaccess: "hrw",\n\
      fields: [\n\
        {bits: "31:0", resval: 4294967295, name: "low", desc: "lower 32 bit"}\n\
      ]\n\
    },\n\
    { name: "CFG_FLUSH_THREAD_HIGH",\n\
      desc: "Index-based Thread Flush Configuration [63:32] (upper 32 bit)",\n\
      swaccess: "rw",\n\
      hwaccess: "hrw",\n\
      fields: [\n\
        {bits: "31:0", resval: 4294967295, name: "high", desc: "upper 32 bit"}\n\
      ]\n\
    },')
      reg_before_commit = reg_before_commit + 2

    if CachePartition != 0:
      for i in range(num_parreg):
          f.write(f'''
    {{ name: "CFG_SET_PARTITION{i}_LOW",
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

    if CachePartition == 0:
      num_parreg = 0

    f.write(f'''
    {{ name: "COMMIT_CFG",
      desc: "Commit the configuration",
      swaccess: "rw1s",
      hwaccess: "hrw",
      fields: [
        {{bits: "0", name: "commit", desc: "commit configuration"}}
      ]
    }},
    {{skipto: "{hex(reg_before_commit * 4 + (num_parreg + 1) * 0x08)}"}}
''')

    if CachePartition != 0:
      f.write(f'''    {{ name: "COMMIT_PARTITION_CFG",
      desc: "Commit the set partition configuration",
      swaccess: "rw1s",
      hwaccess: "hrw",
      fields: [
        {{bits: "0", name: "commit", desc: "commit set partition configuration"}}
      ]
    }},
    {{skipto: "{hex(reg_before_commit * 4 + (num_parreg + 2) * 0x08)}"}}
''')

    f.write(f'''    {{ name: "FLUSHED_LOW",
      desc: "Flushed Flag (lower 32 bit)",
      swaccess: "ro",
      hwaccess: "hrw",
      fields: [
        {{bits: "31:0", name: "low", desc: "lower 32 bit"}}
      ]
    }},
    {{ name: "FLUSHED_HIGH",
      desc: "Flushed Flag (upper 32 bit)",
      swaccess: "ro",
      hwaccess: "hrw",
      fields: [
        {{bits: "31:0", name: "high", desc: "upper 32 bit"}}
      ]
    }},
    {{ name: "BIST_OUT_LOW",
      desc: "Tag Storage BIST Result (lower 32 bit)",
      swaccess: "ro",
      hwaccess: "hwo",
      fields: [
        {{bits: "31:0", name: "low", desc: "lower 32 bit"}}
      ]
    }},
    {{ name: "BIST_OUT_HIGH",
      desc: "Tag Storage BIST Result (upper 32 bit)",
      swaccess: "ro",
      hwaccess: "hwo",
      fields: [
        {{bits: "31:0", name: "high", desc: "upper 32 bit"}}
      ]
    }},
    {{ name: "SET_ASSO_LOW",
      desc: "Instantiated Set-Associativity (lower 32 bit)",
      swaccess: "ro",
      hwaccess: "hwo",
      fields: [
        {{bits: "31:0", name: "low", desc: "lower 32 bit"}}
      ]
    }},
    {{ name: "SET_ASSO_HIGH",
      desc: "Instantiated Set-Associativity (upper 32 bit)",
      swaccess: "ro",
      hwaccess: "hwo",
      fields: [
        {{bits: "31:0", name: "high", desc: "upper 32 bit"}}
      ]
    }},
    {{ name: "NUM_LINES_LOW",
      desc: "Instantiated Number of Cache-Lines (lower 32 bit)",
      swaccess: "ro",
      hwaccess: "hwo",
      fields: [
        {{bits: "31:0", name: "low", desc: "lower 32 bit"}}
      ]
    }},
    {{ name: "NUM_LINES_HIGH",
      desc: "Instantiated Number of Cache-Lines (upper 32 bit)",
      swaccess: "ro",
      hwaccess: "hwo",
      fields: [
        {{bits: "31:0", name: "high", desc: "upper 32 bit"}}
      ]
    }},
    {{ name: "NUM_BLOCKS_LOW",
      desc: "Instantiated Number of Blocks (lower 32 bit)",
      swaccess: "ro",
      hwaccess: "hwo",
      fields: [
        {{bits: "31:0", name: "low", desc: "lower 32 bit"}}
      ]
    }},
    {{ name: "NUM_BLOCKS_HIGH",
      desc: "Instantiated Number of Blocks (upper 32 bit)",
      swaccess: "ro",
      hwaccess: "hwo",
      fields: [
        {{bits: "31:0", name: "high", desc: "upper 32 bit"}}
      ]
    }},
    {{ name: "VERSION_LOW",
      desc: "AXI LLC Version (lower 32 bit)",
      swaccess: "ro",
      hwaccess: "hwo",
      fields: [
        {{bits: "31:0", name: "low", desc: "lower 32 bit"}}
      ]
    }},
    {{ name: "VERSION_HIGH",
      desc: "AXI LLC Version (upper 32 bit)",
      swaccess: "ro",
      hwaccess: "hwo",
      fields: [
        {{bits: "31:0", name: "high", desc: "upper 32 bit"}}
      ]
    }},
    {{ name: "BIST_STATUS",
      desc: "Status register of the BIST",
      swaccess: "ro",
      hwaccess: "hwo",
      fields: [
        {{bits: "0:0", name: "done", desc: "BIST successfully completed"}}
      ]
    }}''')

    if CachePartition != 0:
      f.write(',\n')
    else: 
      f.write('\n')

    if CachePartition != 0:
      for i in range(num_setflushreg):
          f.write(f'''    {{ name: "FLUSHED_SET{i}_LOW",
      desc: "Index-based Flushed Flag [{(2*i+1)*32-1}:{2*i*32}] (lower 32 bit)",
      swaccess: "ro",
      hwaccess: "hrw",
      fields: [
        {{bits: "31:0", name: "low", desc: "lower 32 bit"}}
      ]
    }},
    {{ name: "FLUSHED_SET{i}_HIGH",
      desc: "Index-based Flushed Flag [{2*(i+1)*32-1}:{(2*i+1)*32}] (upper 32 bit)",
      swaccess: "ro",
      hwaccess: "hrw",
      fields: [
        {{bits: "31:0", name: "high", desc: "upper 32 bit"}}
      ]
    }}''')
          if (i != num_setflushreg-1):
            f.write(',\n')
          else: 
            f.write('\n')

    f.write('  ]\n}\n')

print('Successfully generate the reggen content related to set-based partition configuration registers in "set_partition_reggen.hjson"!')