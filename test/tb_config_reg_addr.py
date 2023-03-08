# This file is used to generate the concat command in 'axi_llc_config.sv'

import math
import sys
# all variables below are just for verification
RegWidth    = int(sys.argv[1]) # 64 Same as "RegWidth" in sv
NumLines    = int(sys.argv[2]) # 256 Same as "Sfg.NumLines in sv
MaxThread   = int(sys.argv[3]) # 256 Same as "MaxThread" in sv
IndexLength = math.ceil(math.log2(NumLines))  # Same as "Cfg.IndexLength" in sv
num_setflushreg = math.ceil(NumLines / RegWidth)
num_parreg  = math.ceil(MaxThread / math.floor(RegWidth / IndexLength))  # The number of configuration registers used for set partitioning.
valid_reg_bit = math.floor(RegWidth / IndexLength) * IndexLength


with open('test/tb_config_reg_addr.hjson', 'w') as f:
    f.write(f'''  // Config register addresses
  typedef enum logic [31:0] {{
    CfgSpmLow     = 32'h00,
    CfgSpmHigh    = 32'h04,
    CfgFlushLow   = 32'h08,
    CfgFlushHigh  = 32'h0C,
''')
    for i in range(num_setflushreg):
        f.write(f'''    CfgFlushSet{i}Low  = 32'h{hex(0x10 + i * 0x08)[2:]},
    CfgFlushSet{i}High = 32'h{hex(0x14 + i * 0x08)[2:]},
''')
    for i in range(num_parreg):
        f.write(f'''    CfgSetPartition{i}Low = 32'h{hex(((4 + 2 * num_setflushreg) * 4 + i * 0x08))[2:]},
    CfgSetPartition{i}High = 32'h{hex(((4 + 2 * num_setflushreg) * 4 + 4 + i * 0x08))[2:]},
''')
    f.write(f'''    CommitCfg     = 32'h{hex(((4+2*num_setflushreg)*4 + num_parreg * 0x08))[2:]},
    CommitPadding = 32'h{hex(((4 + 2 * num_setflushreg) * 4 + 4 + num_parreg * 0x08))[2:]},
    CommitPartitionCfg     = 32'h{hex(((4 + 2 * num_setflushreg) * 4 + (num_parreg + 1) * 0x08))[2:]},
    CommitPartitionPadding = 32'h{hex(((4 + 2 * num_setflushreg) * 4 + 4 + (num_parreg + 1) * 0x08))[2:]},
    FlushedLow    = 32'h{hex(((4 + 2 * num_setflushreg) * 4 + (num_parreg + 2) * 0x08))[2:]},
    FlushedHigh   = 32'h{hex(((4 + 2 * num_setflushreg) * 4 + 4 + (num_parreg + 2) * 0x08))[2:]},
    BistOutLow    = 32'h{hex(((4 + 2 * num_setflushreg) * 4 + (num_parreg + 3) * 0x08))[2:]},
    BistOutHigh   = 32'h{hex(((4 + 2 * num_setflushreg) * 4 + 4 + (num_parreg + 3) * 0x08))[2:]},
    SetAssoLow    = 32'h{hex(((4 + 2 * num_setflushreg) * 4 + (num_parreg + 4) * 0x08))[2:]},
    SetAssoHigh   = 32'h{hex(((4 + 2 * num_setflushreg) * 4 + 4 + (num_parreg + 4) * 0x08))[2:]},
    NumLinesLow   = 32'h{hex(((4 + 2 * num_setflushreg) * 4 + (num_parreg + 5) * 0x08))[2:]},
    NumLinesHigh  = 32'h{hex(((4 + 2 * num_setflushreg) * 4 + 4 + (num_parreg + 5) * 0x08))[2:]},
    NumBlocksLow  = 32'h{hex(((4 + 2 * num_setflushreg) * 4 + (num_parreg + 6) * 0x08))[2:]},
    NumBlocksHigh = 32'h{hex(((4 + 2 * num_setflushreg) * 4 + 4 + (num_parreg + 6) * 0x08))[2:]},
    VersionLow    = 32'h{hex(((4 + 2 * num_setflushreg) * 4 + (num_parreg + 7) * 0x08))[2:]},
    VersionHigh   = 32'h{hex(((4 + 2 * num_setflushreg) * 4 + 4 + (num_parreg + 7) * 0x08))[2:]},
''')

    for i in range(num_setflushreg):
        f.write(f'''    FlushedSet{i}Low  = 32'h{hex(((4 + 2 * num_setflushreg) * 4 + (num_parreg + 7) * 0x08 + 8 + i * 0x08))[2:]},
    FlushedSet{i}High  = 32'h{hex(((4 + 2 * num_setflushreg) * 4 + (num_parreg + 7) * 0x08 + 12+ i * 0x08))[2:]}''')
        if (i != num_setflushreg-1):
            f.write(',\n')
        else: 
            f.write('\n')

    f.write(f'''  }} llc_cfg_addr_e;''')

print(f'The register addr is successfully generated in "./onfig_reg_addr.hjson"!')