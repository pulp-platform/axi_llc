
# This file is used to generate the concat command in 'axi_llc_config.sv'

import math
import sys
# all variables below are just for verification
RegWidth    = int(sys.argv[1]) # 64 Same as "RegWidth" in sv
NumLines    = int(sys.argv[2]) # 256 Same as "Sfg.NumLines in sv
MaxPartition   = int(sys.argv[3]) # 256 Same as "MaxPartition" in sv
IndexLength = math.ceil(math.log2(NumLines))  # Same as "Cfg.IndexLength" in sv
num_setflushreg = math.ceil(NumLines / RegWidth)
num_setflushthread = 1
num_parreg  = math.ceil(MaxPartition / math.floor(RegWidth / IndexLength))  # The number of configuration registers used for set partitioning.
valid_reg_bit = math.floor(RegWidth / IndexLength) * IndexLength


with open('test/tb_config_reg_addr.hjson', 'w') as f:
    f.write(f'''  // Config register addresses
  typedef enum logic [31:0] {{
    CfgSpmLow     = 32'h00,
    CfgSpmHigh    = 32'h04,
    CfgFlushLow   = 32'h08,
    CfgFlushHigh  = 32'h0C,
    CommitCfg     = 32'h10,
    CommitPadding = 32'h14,
    FlushedLow    = 32'h18,
    FlushedHigh   = 32'h1C,
    BistOutLow    = 32'h20,
    BistOutHigh   = 32'h24,
    SetAssoLow    = 32'h28,
    SetAssoHigh   = 32'h2C,
    NumLinesLow   = 32'h30,
    NumLinesHigh  = 32'h34,
    NumBlocksLow  = 32'h38,
    NumBlocksHigh = 32'h3C,
    VersionLow    = 32'h40,
    VersionHigh   = 32'h44,
    BistStatus    = 32'h48,
''')
    for i in range(num_setflushthread):
        f.write(f'''    CfgFlushThreadLow    = 32'h{hex(0x4c + i * 0x08)[2:]},
    CfgFlushThreadHigh   = 32'h{hex(0x50 + i * 0x08)[2:]},
''')
    for i in range(num_parreg):
        f.write(f'''    CfgSetPartitionLow{i}  = 32'h{hex(0x54 + i * 0x04)[2:]},
''')
    temp = 0x54 + i * 0x04
    for i in range(num_parreg):
        f.write(f'''    CfgSetPartitionHigh{i} = 32'h{hex(temp + 0x04 + i * 0x04)[2:]},
''')
    f.write(f'''    CommitPartitionCfg     = 32'h{hex(0x58 + (num_parreg - 1) * 0x08 + 0x04)[2:]},
    CommitPartitionPadding = 32'h{hex(0x58 + (num_parreg - 1) * 0x08 + 0x08)[2:]},
''')

    for i in range(num_setflushreg):
        f.write(f'''    FlushedSetLow{i}   = 32'h{hex(0x58 + num_parreg * 0x08  + 0x04 + i * 0x04)[2:]},
''')

    temp = 0x58 + num_parreg * 0x08  + 0x04 + i * 0x04

    for i in range(num_setflushreg):
        f.write(f'''    FlushedSetHigh{i}  = 32'h{hex(temp  + 0x04 + i * 0x04)[2:]}''')
        if (i != num_setflushreg-1):
            f.write(',\n')
        else: 
            f.write('\n')

    f.write(f'''  }} llc_cfg_addr_e;''')

print(f'The register addr is successfully generated in "./onfig_reg_addr.hjson"!')