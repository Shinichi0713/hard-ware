Readme_VHDL

�����̃t�@�C���́A�uVHDL ����҃g���C�A���E�R�[�X�v�Ŏ��{���Ă��鉉�K�̃f�[�^�ł��B
�܂��AWeb �y�[�W�Ō��J���Ă���u�͂��߂Ă݂悤�I�e�X�g�x���`�v�̃T���v���Ƃ��Ă��񋟂��Ă��܂��B

���K�����{����ɂ́A�Ⴆ�Ή��K�@�iLab1�j�̏ꍇ�� lab1 �t�H���_����ƃt�H���_�ɂ��ăf�U�C���� VHDL �ŋL�q���A�V�~�����[�V�����œ�����m�F���Ă��������B
�V�~�����[�V�����ɗp����e�X�g�x���`�́A�p�ӂ���Ă��܂��B

Solution �t�H���_���ɂ́A�e���K�̃T���v���L�q���p�ӂ���Ă��܂��̂ŁA�Q�l�ɂ��Ă��������B


���K�@�iLab1�j

<�ړI>
�E�L�q�̌����߂����A���Z������������܂��B

�E�G���e�B�e�B���Fadder
�E���̓|�[�g�Fa (16bit), b (16bit)
�E�o�̓|�[�g�Fsum (16bit)
�E�f�[�^�E�^�C�v�Fstd_logic_vector
�E�@�\�F16�r�b�g���Z��


���K�A�iLab2�j

<�ړI>
�Ewhen-else ���Ŕ�r����쐬���܂��B

�E�G���e�B�e�B���Fcompare
�E���̓|�[�g�Fda (8bit), db (8bit)
�E�o�̓|�[�g�Fequ, agb, alb (1bit)
�E�f�[�^�E�^�C�v�Fstd_logic, std_logic_vector
�E�@�\�F��r��

<�������>
���͐M�� da �� db ���r���܂��B
�Eda �� db ���������ꍇ�́Aequ �� High (1) ���o�͂��A����ȊO�̂Ƃ��� Low (0) ���o��
�Eda ���傫���ꍇ�́Aagb �� High (1) ���o�͂��A����ȊO�̂Ƃ��� Low (0) ���o��
�Edb ���傫���ꍇ�́Aalb �� High (1) ���o�͂��A����ȊO�̂Ƃ��� Low (0) ���o��


���K�B�iLab3�j

<�ړI>
�Eprocess ���ŏ�Z����쐬���܂��B

�E�G���e�B�e�B���Fmult4x4
�E���̓|�[�g�Fa (4bit), b (4bit)
�E�o�̓|�[�g�Fproduct (8bit)
�E�f�[�^�E�^�C�v�Fstd_logic_vector
�E�@�\�F4x4bit ��Z��


���K�C�iLab4�j

<�ړI>
�E���K�A�̔�r��� if-else ���ō쐬���܂��B

�E�G���e�B�e�B���Fcompare_if
�E���̓|�[�g�Fda (8bit), db (8bit)
�E�o�̓|�[�g�Fequ, agb, alb (1bit)
�E�f�[�^�E�^�C�v�Fstd_logic, std_logic_vector
�E�@�\�F��r��

<�������>
���͐M�� da �� db ���r���܂��B
�Eda �� db ���������ꍇ�́Aequ �� High (1) ���o�͂��A����ȊO�̂Ƃ��� Low (0) ���o��
�Eda ���傫���ꍇ�́Aagb �� High (1) ���o�͂��A����ȊO�̂Ƃ��� Low (0) ���o��
�Edb ���傫���ꍇ�́Aalb �� High (1) ���o�͂��A����ȊO�̂Ƃ��� Low (0) ���o��


���K�D�iLab5�j

<�ړI>
�Ecase �����g�p���A�}���`�v���N�T���쐬���܂��B

�E�G���e�B�e�B���Fmux4
�E���̓|�[�g�Fa (4bit), b (4bit), sel (1bit)
�E�o�̓|�[�g�Fy (4bit)
�E�f�[�^�E�^�C�v�Fstd_logic, std_logic_vector
�E�@�\�F2 to 1 �}���`�v���N�T

<�������>
�E�Z���N�g�E�R���g���[���M�� (sel) �� Low (0) �Ȃ�� a[3..0] ���o��
�E�Z���N�g�E�R���g���[���M�� (sel) �� High (1) �Ȃ�� b[3..0] ���o��


���K�E�iLab6�j

<�ړI>
�E�񓯊��N���A&�N���b�N�E�C�l�[�u���t���t���b�v�t���b�v���쐬���܂��B

�E�G���e�B�e�B���Fff
�E���̓|�[�g�Fclk (1bit), aclr (1bit), clken (1bit)
�E���̓|�[�g�Fd (1bit)
�E�o�̓|�[�g�Fq (1bit)
�E�f�[�^�E�^�C�v�Fstd_logic
�E�@�\�F�񓯊��N���A&�N���b�N�E�C�l�[�u���t���t���b�v�t���b�v

<�������>
�E�N���A�M�� (aclr) �� Low (0) �̂Ƃ��A�t���b�v�t���b�v�� Low (0) ���o�͂���i�N���A�����j
�E�N���A�M�� (aclr) �� High (1)�A���N���b�N�E�C�l�[�u���M�� (clken) �� High (1) �̂Ƃ��A�o�� q �� ���� d ���o�͂���

