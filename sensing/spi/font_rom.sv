module font_rom (
    input  logic [6:0] ascii,   // 0x20 - 0x7E
    input  logic [2:0] col,     // 0 - 4
    output logic [7:0] pattern  // bit[row] = ドット
);
    logic [7:0] font [0:474];   // 95 chars * 5 cols

    initial begin
        // 0x20 ' '
        font[0]=8'h00; font[1]=8'h00; font[2]=8'h00; font[3]=8'h00; font[4]=8'h00;
        // 0x21 '!'
        font[5]=8'h00; font[6]=8'h5E; font[7]=8'h00; font[8]=8'h00; font[9]=8'h00;
        // 0x22 '"'
        font[10]=8'h00; font[11]=8'h07; font[12]=8'h00; font[13]=8'h07; font[14]=8'h00;
        // 0x23 '#'
        font[15]=8'h14; font[16]=8'h3E; font[17]=8'h14; font[18]=8'h3E; font[19]=8'h14;
        // 0x24 '$'
        font[20]=8'h24; font[21]=8'h2A; font[22]=8'h7F; font[23]=8'h2A; font[24]=8'h12;
        // 0x25 '%'
        font[25]=8'h23; font[26]=8'h13; font[27]=8'h08; font[28]=8'h64; font[29]=8'h62;
        // 0x26 '&'
        font[30]=8'h36; font[31]=8'h49; font[32]=8'h55; font[33]=8'h22; font[34]=8'h50;
        // 0x27 '''
        font[35]=8'h00; font[36]=8'h00; font[37]=8'h07; font[38]=8'h00; font[39]=8'h00;
        // 0x28 '('
        font[40]=8'h00; font[41]=8'h1C; font[42]=8'h22; font[43]=8'h41; font[44]=8'h00;
        // 0x29 ')'
        font[45]=8'h00; font[46]=8'h41; font[47]=8'h22; font[48]=8'h1C; font[49]=8'h00;
        // 0x2A '*'
        font[50]=8'h2A; font[51]=8'h1C; font[52]=8'h7F; font[53]=8'h1C; font[54]=8'h2A;
        // 0x2B '+'
        font[55]=8'h08; font[56]=8'h08; font[57]=8'h3E; font[58]=8'h08; font[59]=8'h08;
        // 0x2C ','
        font[60]=8'h00; font[61]=8'hA0; font[62]=8'h60; font[63]=8'h00; font[64]=8'h00;
        // 0x2D '-'
        font[65]=8'h08; font[66]=8'h08; font[67]=8'h08; font[68]=8'h08; font[69]=8'h08;
        // 0x2E '.'
        font[70]=8'h00; font[71]=8'h60; font[72]=8'h60; font[73]=8'h00; font[74]=8'h00;
        // 0x2F '/'
        font[75]=8'h20; font[76]=8'h10; font[77]=8'h08; font[78]=8'h04; font[79]=8'h02;
        // 0x30 '0'
        font[80]=8'h3E; font[81]=8'h51; font[82]=8'h49; font[83]=8'h45; font[84]=8'h3E;
        // 0x31 '1'
        font[85]=8'h00; font[86]=8'h42; font[87]=8'h7F; font[88]=8'h40; font[89]=8'h00;
        // 0x32 '2'
        font[90]=8'h62; font[91]=8'h51; font[92]=8'h49; font[93]=8'h49; font[94]=8'h46;
        // 0x33 '3'
        font[95]=8'h22; font[96]=8'h41; font[97]=8'h49; font[98]=8'h49; font[99]=8'h36;
        // 0x34 '4'
        font[100]=8'h18; font[101]=8'h14; font[102]=8'h12; font[103]=8'h7F; font[104]=8'h10;
        // 0x35 '5'
        font[105]=8'h27; font[106]=8'h45; font[107]=8'h45; font[108]=8'h45; font[109]=8'h39;
        // 0x36 '6'
        font[110]=8'h3C; font[111]=8'h4A; font[112]=8'h49; font[113]=8'h49; font[114]=8'h30;
        // 0x37 '7'
        font[115]=8'h01; font[116]=8'h71; font[117]=8'h09; font[118]=8'h05; font[119]=8'h03;
        // 0x38 '8'
        font[120]=8'h36; font[121]=8'h49; font[122]=8'h49; font[123]=8'h49; font[124]=8'h36;
        // 0x39 '9'
        font[125]=8'h06; font[126]=8'h49; font[127]=8'h49; font[128]=8'h29; font[129]=8'h1E;
        // 0x3A ':'
        font[130]=8'h00; font[131]=8'h36; font[132]=8'h36; font[133]=8'h00; font[134]=8'h00;
        // 0x3B ';'
        font[135]=8'h00; font[136]=8'hA6; font[137]=8'h66; font[138]=8'h00; font[139]=8'h00;
        // 0x3C '<'
        font[140]=8'h00; font[141]=8'h1C; font[142]=8'h22; font[143]=8'h41; font[144]=8'h00;
        // 0x3D '='
        font[145]=8'h14; font[146]=8'h14; font[147]=8'h14; font[148]=8'h14; font[149]=8'h14;
        // 0x3E '>'
        font[150]=8'h00; font[151]=8'h41; font[152]=8'h22; font[153]=8'h1C; font[154]=8'h00;
        // 0x3F '?'
        font[155]=8'h02; font[156]=8'h01; font[157]=8'h59; font[158]=8'h09; font[159]=8'h06;
        // 0x40 '@'
        font[160]=8'h3E; font[161]=8'h41; font[162]=8'h5D; font[163]=8'h55; font[164]=8'h1E;
        // 0x41 'A'
        font[165]=8'h7E; font[166]=8'h11; font[167]=8'h11; font[168]=8'h11; font[169]=8'h7E;
        // 0x42 'B'
        font[170]=8'h7F; font[171]=8'h49; font[172]=8'h49; font[173]=8'h49; font[174]=8'h36;
        // 0x43 'C'
        font[175]=8'h3E; font[176]=8'h41; font[177]=8'h41; font[178]=8'h41; font[179]=8'h22;
        // 0x44 'D'
        font[180]=8'h7F; font[181]=8'h41; font[182]=8'h41; font[183]=8'h22; font[184]=8'h1C;
        // 0x45 'E'
        font[185]=8'h7F; font[186]=8'h49; font[187]=8'h49; font[188]=8'h49; font[189]=8'h41;
        // 0x46 'F'
        font[190]=8'h7F; font[191]=8'h09; font[192]=8'h09; font[193]=8'h09; font[194]=8'h01;
        // 0x47 'G'
        font[195]=8'h3E; font[196]=8'h41; font[197]=8'h49; font[198]=8'h49; font[199]=8'h7A;
        // 0x48 'H'
        font[200]=8'h7F; font[201]=8'h08; font[202]=8'h08; font[203]=8'h08; font[204]=8'h7F;
        // 0x49 'I'
        font[205]=8'h00; font[206]=8'h41; font[207]=8'h7F; font[208]=8'h41; font[209]=8'h00;
        // 0x4A 'J'
        font[210]=8'h20; font[211]=8'h40; font[212]=8'h41; font[213]=8'h3F; font[214]=8'h01;
        // 0x4B 'K'
        font[215]=8'h7F; font[216]=8'h08; font[217]=8'h14; font[218]=8'h22; font[219]=8'h41;
        // 0x4C 'L'
        font[220]=8'h7F; font[221]=8'h40; font[222]=8'h40; font[223]=8'h40; font[224]=8'h40;
        // 0x4D 'M'
        font[225]=8'h7F; font[226]=8'h02; font[227]=8'h0C; font[228]=8'h02; font[229]=8'h7F;
        // 0x4E 'N'
        font[230]=8'h7F; font[231]=8'h04; font[232]=8'h08; font[233]=8'h10; font[234]=8'h7F;
        // 0x4F 'O'
        font[235]=8'h3E; font[236]=8'h41; font[237]=8'h41; font[238]=8'h41; font[239]=8'h3E;
        // 0x50 'P'
        font[240]=8'h7F; font[241]=8'h09; font[242]=8'h09; font[243]=8'h09; font[244]=8'h06;
        // 0x51 'Q'
        font[245]=8'h3E; font[246]=8'h41; font[247]=8'h51; font[248]=8'h21; font[249]=8'h5E;
        // 0x52 'R'
        font[250]=8'h7F; font[251]=8'h09; font[252]=8'h19; font[253]=8'h29; font[254]=8'h46;
        // 0x53 'S'
        font[255]=8'h26; font[256]=8'h49; font[257]=8'h49; font[258]=8'h49; font[259]=8'h32;
        // 0x54 'T'
        font[260]=8'h01; font[261]=8'h01; font[262]=8'h7F; font[263]=8'h01; font[264]=8'h01;
        // 0x55 'U'
        font[265]=8'h3F; font[266]=8'h40; font[267]=8'h40; font[268]=8'h40; font[269]=8'h3F;
        // 0x56 'V'
        font[270]=8'h1F; font[271]=8'h20; font[272]=8'h40; font[273]=8'h20; font[274]=8'h1F;
        // 0x57 'W'
        font[275]=8'h3F; font[276]=8'h40; font[277]=8'h38; font[278]=8'h40; font[279]=8'h3F;
        // 0x58 'X'
        font[280]=8'h63; font[281]=8'h14; font[282]=8'h08; font[283]=8'h14; font[284]=8'h63;
        // 0x59 'Y'
        font[285]=8'h07; font[286]=8'h08; font[287]=8'h70; font[288]=8'h08; font[289]=8'h07;
        // 0x5A 'Z'
        font[290]=8'h61; font[291]=8'h51; font[292]=8'h49; font[293]=8'h45; font[294]=8'h43;
        // 0x5B '['
        font[295]=8'h00; font[296]=8'h7F; font[297]=8'h41; font[298]=8'h41; font[299]=8'h00;
        // 0x5C '\'
        font[300]=8'h02; font[301]=8'h04; font[302]=8'h08; font[303]=8'h10; font[304]=8'h20;
        // 0x5D ']'
        font[305]=8'h00; font[306]=8'h41; font[307]=8'h41; font[308]=8'h7F; font[309]=8'h00;
        // 0x5E '^'
        font[310]=8'h04; font[311]=8'h02; font[312]=8'h01; font[313]=8'h02; font[314]=8'h04;
        // 0x5F '_'
        font[315]=8'h40; font[316]=8'h40; font[317]=8'h40; font[318]=8'h40; font[319]=8'h40;
        // 0x60 '`'
        font[320]=8'h00; font[321]=8'h01; font[322]=8'h02; font[323]=8'h04; font[324]=8'h00;
        // 0x61 'a'
        font[325]=8'h20; font[326]=8'h54; font[327]=8'h54; font[328]=8'h54; font[329]=8'h78;
        // 0x62 'b'
        font[330]=8'h7F; font[331]=8'h48; font[332]=8'h44; font[333]=8'h44; font[334]=8'h38;
        // 0x63 'c'
        font[335]=8'h38; font[336]=8'h44; font[337]=8'h44; font[338]=8'h44; font[339]=8'h28;
        // 0x64 'd'
        font[340]=8'h38; font[341]=8'h44; font[342]=8'h44; font[343]=8'h48; font[344]=8'h7F;
        // 0x65 'e'
        font[345]=8'h38; font[346]=8'h54; font[347]=8'h54; font[348]=8'h54; font[349]=8'h18;
        // 0x66 'f'
        font[350]=8'h08; font[351]=8'h7E; font[352]=8'h09; font[353]=8'h01; font[354]=8'h02;
        // 0x67 'g'
        font[355]=8'h18; font[356]=8'hA4; font[357]=8'hA4; font[358]=8'hA4; font[359]=8'h7C;
        // 0x68 'h'
        font[360]=8'h7F; font[361]=8'h08; font[362]=8'h04; font[363]=8'h04; font[364]=8'h78;
        // 0x69 'i'
        font[365]=8'h00; font[366]=8'h44; font[367]=8'h7D; font[368]=8'h40; font[369]=8'h00;
        // 0x6A 'j'
        font[370]=8'h20; font[371]=8'h40; font[372]=8'h44; font[373]=8'h3D; font[374]=8'h00;
        // 0x6B 'k'
        font[375]=8'h7F; font[376]=8'h10; font[377]=8'h28; font[378]=8'h44; font[379]=8'h00;
        // 0x6C 'l'
        font[380]=8'h00; font[381]=8'h41; font[382]=8'h7F; font[383]=8'h40; font[384]=8'h00;
        // 0x6D 'm'
        font[385]=8'h7C; font[386]=8'h04; font[387]=8'h78; font[388]=8'h04; font[389]=8'h78;
        // 0x6E 'n'
        font[390]=8'h7C; font[391]=8'h08; font[392]=8'h04; font[393]=8'h04; font[394]=8'h78;
        // 0x6F 'o'
        font[395]=8'h38; font[396]=8'h44; font[397]=8'h44; font[398]=8'h44; font[399]=8'h38;
        // 0x70 'p'
        font[400]=8'h7C; font[401]=8'h14; font[402]=8'h14; font[403]=8'h14; font[404]=8'h08;
        // 0x71 'q'
        font[405]=8'h08; font[406]=8'h14; font[407]=8'h14; font[408]=8'h18; font[409]=8'h7C;
        // 0x72 'r'
        font[410]=8'h7C; font[411]=8'h08; font[412]=8'h04; font[413]=8'h04; font[414]=8'h08;
        // 0x73 's'
        font[415]=8'h48; font[416]=8'h54; font[417]=8'h54; font[418]=8'h54; font[419]=8'h24;
        // 0x74 't'
        font[420]=8'h04; font[421]=8'h3F; font[422]=8'h44; font[423]=8'h40; font[424]=8'h20;
        // 0x75 'u'
        font[425]=8'h3C; font[426]=8'h40; font[427]=8'h40; font[428]=8'h20; font[429]=8'h7C;
        // 0x76 'v'
        font[430]=8'h1C; font[431]=8'h20; font[432]=8'h40; font[433]=8'h20; font[434]=8'h1C;
        // 0x77 'w'
        font[435]=8'h3C; font[436]=8'h40; font[437]=8'h30; font[438]=8'h40; font[439]=8'h3C;
        // 0x78 'x'
        font[440]=8'h44; font[441]=8'h28; font[442]=8'h10; font[443]=8'h28; font[444]=8'h44;
        // 0x79 'y'
        font[445]=8'h0C; font[446]=8'h50; font[447]=8'h50; font[448]=8'h50; font[449]=8'h3C;
        // 0x7A 'z'
        font[450]=8'h44; font[451]=8'h64; font[452]=8'h54; font[453]=8'h4C; font[454]=8'h44;
        // 0x7B '{'
        font[455]=8'h00; font[456]=8'h08; font[457]=8'h36; font[458]=8'h41; font[459]=8'h00;
        // 0x7C '|'
        font[460]=8'h00; font[461]=8'h7F; font[462]=8'h00; font[463]=8'h00; font[464]=8'h00;
        // 0x7D '}'
        font[465]=8'h00; font[466]=8'h41; font[467]=8'h36; font[468]=8'h08; font[469]=8'h00;
        // 0x7E '~'
        font[470]=8'h08; font[471]=8'h08; font[472]=8'h2A; font[473]=8'h1C; font[474]=8'h08;
    end

    always_comb begin
        if (ascii < 7'h20 || ascii > 7'h7E)
            pattern = 8'h00;
        else
            pattern = font[(ascii - 7'h20) * 5 + col];
    end
endmodule