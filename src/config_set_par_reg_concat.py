# This file is used to generate the concat command in 'axi_llc_config.sv'

import math
num_parreg  = 4  # The number of configuration registers used for set partitioning.
# all variables below are just for verification
RegWidth    = 64 # Same as "RegWidth" in sv
IndexLength = 8  # Same as "Cfg.IndexLength" in sv
valid_reg_bit = math.floor(RegWidth / IndexLength) * IndexLength

print(f'Each configration register can hold {math.floor(RegWidth / IndexLength)} partition sizes')
print(f'Number of valid bits in set partition configuration register is : {valid_reg_bit}')

with open('config_set_par_reg_concat.hjson', 'w') as f:
    f.write('assign conf_regs_i_cfg_set_partition = {')
    for i in range(num_parreg-1):
        f.write(f'''conf_regs_i.cfg_set_partition{num_parreg-1-i}[valid_reg_bit-1:0], 
                                        ''')
    f.write('conf_regs_i.cfg_set_partition0[valid_reg_bit-1:0]};')

print(f'The command is successfully generated in "./config_set_par_reg_concat.hjson!"')