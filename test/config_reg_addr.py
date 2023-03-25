# This file is used to generate the concat command in 'axi_llc_config.sv'

import math
num_parreg  = 4  # The number of configuration registers used for set partitioning.
# all variables below are just for verification
RegWidth    = 64 # Same as "RegWidth" in sv
IndexLength = 8  # Same as "Cfg.IndexLength" in sv
valid_reg_bit = math.floor(RegWidth / IndexLength) * IndexLength


with open('config_reg_addr.hjson', 'w') as f:
    f.write(f'''  // Config register addresses
  typedef enum logic [31:0] {{
    CfgSpmLow     = 32'h00,
    CfgSpmHigh    = 32'h04,
    CfgFlushLow   = 32'h08,
    CfgFlushHigh  = 32'h0C,
    CfgFlushSet0Low  = 32'h10,
    CfgFlushSet0High = 32'h14,
    CfgFlushSet1Low  = 32'h18,
    CfgFlushSet1High = 32'h1c,
    CfgFlushSet2Low  = 32'h20,
    CfgFlushSet2High = 32'h24,
    CfgFlushSet3Low  = 32'h28,
    CfgFlushSet3High = 32'h2c,
''')
    for i in range(num_parreg):
        f.write(f'''    CfgSetPartition{i}Low = 32'h{hex(0x30 + i * 0x08)[2:]},
    CfgSetPartition{i}High = 32'h{hex(0x34 + i * 0x08)[2:]},
''')
    f.write(f'''    CommitCfg     = 32'h{hex(0x30 + num_parreg * 0x08)[2:]},
    CommitPadding = 32'h{hex(0x34 + num_parreg * 0x08)[2:]},
    CommitPartitionCfg     = 32'h{hex(0x30 + (num_parreg + 1) * 0x08)[2:]},
    CommitPartitionPadding = 32'h{hex(0x34 + (num_parreg + 1) * 0x08)[2:]},
    FlushedLow    = 32'h{hex(0x30 + (num_parreg + 2) * 0x08)[2:]},
    FlushedHigh   = 32'h{hex(0x34 + (num_parreg + 2) * 0x08)[2:]},
    BistOutLow    = 32'h{hex(0x30 + (num_parreg + 3) * 0x08)[2:]},
    BistOutHigh   = 32'h{hex(0x34 + (num_parreg + 3) * 0x08)[2:]},
    SetAssoLow    = 32'h{hex(0x30 + (num_parreg + 4) * 0x08)[2:]},
    SetAssoHigh   = 32'h{hex(0x34 + (num_parreg + 4) * 0x08)[2:]},
    NumLinesLow   = 32'h{hex(0x30 + (num_parreg + 5) * 0x08)[2:]},
    NumLinesHigh  = 32'h{hex(0x34 + (num_parreg + 5) * 0x08)[2:]},
    NumBlocksLow  = 32'h{hex(0x30 + (num_parreg + 6) * 0x08)[2:]},
    NumBlocksHigh = 32'h{hex(0x34 + (num_parreg + 6) * 0x08)[2:]},
    VersionLow    = 32'h{hex(0x30 + (num_parreg + 7) * 0x08)[2:]},
    VersionHigh   = 32'h{hex(0x34 + (num_parreg + 7) * 0x08)[2:]},
    FlushedSet0Low  = 32'h{hex(0x30 + (num_parreg + 8) * 0x08)[2:]},
    FlushedSet0High  = 32'h{hex(0x34 + (num_parreg + 8) * 0x08)[2:]},
    FlushedSet1Low  = 32'h{hex(0x30 + (num_parreg + 9) * 0x08)[2:]},
    FlushedSet1High  = 32'h{hex(0x34 + (num_parreg + 9) * 0x08)[2:]},
    FlushedSet2Low  = 32'h{hex(0x30 + (num_parreg + 10) * 0x08)[2:]},
    FlushedSet2High  = 32'h{hex(0x34 + (num_parreg + 10) * 0x08)[2:]},
    FlushedSet3Low  = 32'h{hex(0x30 + (num_parreg + 11) * 0x08)[2:]},
    FlushedSet3High  = 32'h{hex(0x34 + (num_parreg + 11) * 0x08)[2:]}
  }} llc_cfg_addr_e;''')

print(f'The register addr is successfully generated in "./onfig_reg_addr.hjson"!')