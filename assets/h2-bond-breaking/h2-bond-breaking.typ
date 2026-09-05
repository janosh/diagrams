#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line, rect

// H2 in STO-3G: fixed nuclei, nonrelativistic Hamiltonian, no fitted curve shapes.
// Tabulated data below were calculated from normalized contracted s-Gaussian integrals.
// H exponents: 3.42525091, 0.62391373, 0.16885540 bohr^-2.
// Contraction coefficients: 0.15432897, 0.53532814, 0.44463454.
// RHF: doubly occupied gerade orbital. UHF: minimize over opposite g/u rotations.
// FCI: diagonalize the 2x2 gerade singlet block; checked against the full four-state
// alpha/beta product space at R = 0.45, 0.74, 1.2, 2, 6, 30 A.
// At 0.74 A: RHF = -1.1167593074 Eh; FCI = -1.1372838345 Eh.
// Isolated H = -0.4665818496 Eh in this basis. The chart subtracts twice this value.
// Natural occupations are twice the squared g^2/u^2 configuration amplitudes.
// The atomic probability cartoons and spatial wavefunction formula use R -> infinity;
// A and B are normalized, nonoverlapping 1s orbitals. The singlet spin factor is implicit.
// Sources: Fuchs et al., JCP 122, 094116 (2005), doi:10.1063/1.1858371;
// Burke, The ABC of DFT, chapters 4, 7, 11, 13; Hehre et al., JCP 51, 2657 (1969).
#set page(width: auto, height: auto, margin: 0pt, fill: white)
#set text(font: "Avenir Next", size: 14pt, fill: rgb("#20334C"))
#set par(leading: 0.5em)
#set math.equation(numbering: none)

#let ink = rgb("#19304E")
#let muted = rgb("#617087")
#let blue = rgb("#2764C3")
#let orange = rgb("#BC502D")
#let purple = rgb("#7948AD")
#let teal = rgb("#087F7C")
#let pale_blue = rgb("#EFF5FD")
#let pale_orange = rgb("#FFF4ED")
#let pale_teal = rgb("#EFF8F5")

#let label(left, top, width, body, size: 14pt, color: ink, weight: "regular", centered: false) = {
  content(
    (left, -top),
    block(width: width * 1pt)[
      #text(size: size, fill: color, weight: weight, if centered { align(center, body) } else {
        body
      })
    ],
    anchor: "north-west",
    padding: 0pt,
  )
}
#let symbol(center_x, center_y, body, size: 24pt, color: ink) = {
  content(
    (center_x, -center_y),
    text(size: size, fill: color, top-edge: "bounds", bottom-edge: "bounds", body),
    anchor: "center",
    padding: 0pt,
  )
}
#let panel(left, top, width, height, fill) = {
  rect((left, -top), (left + width, -top - height), radius: 15, fill: fill, stroke: none)
}
#let connect(start, end, color: muted) = {
  line(start, end, stroke: 1.7pt + color, mark: (end: "stealth", scale: 0.7, fill: color))
}
#let nucleus(center_x, center_y) = {
  circle((center_x, -center_y), radius: 9, fill: ink, stroke: none)
  line((center_x - 4, -center_y), (center_x + 4, -center_y), stroke: 1.2pt + white)
  line((center_x, -center_y - 4), (center_x, -center_y + 4), stroke: 1.2pt + white)
}
#let electron(center_x, center_y, spin) = {
  let direction = if spin == "up" { 1 } else { -1 }
  circle((center_x, -center_y), radius: 9, fill: purple, stroke: none)
  line(
    (center_x, -center_y - direction * 4.5),
    (center_x, -center_y + direction * 4.5),
    stroke: 1.2pt + white,
    mark: (end: "stealth", scale: 0.42, fill: white),
  )
}
#let orbital_cloud(center_x, center_y, radius_x, radius_y, color: blue) = {
  for idx in range(24) {
    let scale = 1 - idx / 30
    circle(
      (center_x, -center_y),
      radius: (radius_x * scale, radius_y * scale),
      fill: color.lighten(95% - idx / 23 * 24%),
      stroke: none,
    )
  }
}

// Columns: R [A], E_RHF - 2E_H, E_UHF - 2E_H, E_FCI - 2E_H [Eh], n_g, n_u.
#let curve_data = (
  (0.3, 0.339335940535, 0.339335940535, 0.331359988305, 1.99509254849, 0.00490745151211),
  (0.325, 0.236279239964, 0.236279239964, 0.227900681554, 1.99464277172, 0.00535722828441),
  (0.35, 0.152708797009, 0.152708797009, 0.143894306676, 1.9941379224, 0.00586207760284),
  (0.375, 0.0845649185931, 0.0845649185931, 0.0752807036227, 1.99357359604, 0.00642640396028),
  (0.4, 0.0288023049251, 0.0288023049251, 0.0190139944613, 1.99294499151, 0.00705500849237),
  (0.45, -0.0543494386122, -0.0543494386122, -0.0652518969214, 1.99147367515, 0.00852632484561),
  (0.475, -0.0849513847429, -0.0849513847429, -0.0964655496514, 1.99061928175, 0.00938071825293),
  (0.5, -0.10983257544, -0.10983257544, -0.121996095371, 1.98967725972, 0.010322740281),
  (0.525, -0.129898443818, -0.129898443818, -0.142749956087, 1.98864076226, 0.0113592377447),
  (0.55, -0.145887037073, -0.145887037073, -0.159466207641, 1.98750256653, 0.012497433472),
  (0.575, -0.158406797671, -0.158406797671, -0.172754354148, 1.98625508455, 0.0137449154462),
  (0.6, -0.167964543159, -0.167964543159, -0.183122307762, 1.98489036469, 0.0151096353108),
  (0.625, -0.174986291082, -0.174986291082, -0.190997220521, 1.98340007963, 0.0165999203655),
  (0.65, -0.179832846558, -0.179832846558, -0.196741085212, 1.98177549814, 0.0182245018582),
  (0.675, -0.182811564713, -0.182811564713, -0.200662516032, 1.98000743939, 0.0199925606118),
  (0.7, -0.184185335876, -0.184185335876, -0.203025754953, 1.97808621099, 0.0219137890089),
  (0.725, -0.184179570007, -0.184179570007, -0.204057677958, 1.97600153366, 0.0239984663356),
  (0.74, -0.183595608281, -0.183595608281, -0.204120135374, 1.97466774704, 0.0253322529562),
  (0.75, -0.182987749822, -0.182987749822, -0.203953368231, 1.9737424573, 0.0262575427009),
  (0.775, -0.180775962626, -0.180775962626, -0.202880664112, 1.97129727461, 0.0287027253931),
  (0.8, -0.177686698358, -0.177686698358, -0.20098396756, 1.96865343924, 0.0313465607553),
  (0.825, -0.173842108796, -0.173842108796, -0.19838750679, 1.96579749551, 0.0342025044904),
  (0.85, -0.169346854805, -0.169346854805, -0.19519817934, 1.96271502629, 0.0372849737073),
  (0.875, -0.16429062058, -0.16429062058, -0.191508054447, 1.95939062513, 0.0406093748655),
  (0.9, -0.158750341899, -0.158750341899, -0.18739658218, 1.95580789707, 0.0441921029255),
  (0.925, -0.152792175846, -0.152792175846, -0.182932537672, 1.95194949172, 0.0480505082802),
  (0.95, -0.146473229088, -0.146473229088, -0.178175718616, 1.94779717069, 0.052202829313),
  (0.975, -0.139843057563, -0.139843057563, -0.173178410166, 1.94333191042, 0.0566680895787),
  (1, -0.132944950194, -0.132944950194, -0.167986631111, 1.93853404041, 0.0614659595939),
  (1.025, -0.125817011009, -0.125817011009, -0.162641176892, 1.93338341596, 0.0666165840427),
  (1.05, -0.118493056522, -0.118493056522, -0.157178477391, 1.92785962413, 0.0721403758735),
  (1.075, -0.111003347519, -0.111003347519, -0.1516312895, 1.92194222067, 0.0780577793349),
  (1.1, -0.103375175904, -0.103375175904, -0.146029245847, 1.91561099548, 0.084389004518),
  (1.125, -0.0956333278956, -0.0956333278956, -0.140399281481, 1.9088462635, 0.0911537364983),
  (1.15, -0.0878004444537, -0.0878004444537, -0.13476595979, 1.90162917726, 0.0983708227355),
  (1.175, -0.0798972985993, -0.0801784712832, -0.12915171756, 1.89394205698, 0.106057943018),
  (1.2, -0.0719430074416, -0.0732088127404, -0.123577047182, 1.88576873306, 0.114231266943),
  (1.225, -0.063955194439, -0.066842059785, -0.118060631635, 1.87709489533, 0.122905104672),
  (1.25, -0.0559501149635, -0.0610264547671, -0.112619445427, 1.86790844248, 0.132091557523),
  (1.275, -0.0479427557704, -0.0557147849465, -0.107268832186, 1.85819982431, 0.141800175691),
  (1.3, -0.0399469166497, -0.0508639152697, -0.102022567311, 1.84796236887, 0.152037631126),
  (1.325, -0.0319752804576, -0.0464343894629, -0.0968929120081, 1.83719258584, 0.162807414157),
  (1.35, -0.0240394759464, -0.0423900866883, -0.0918906633457, 1.82589043724, 0.174109562765),
  (1.375, -0.0161501363548, -0.0386979231224, -0.087025203486, 1.81405956649, 0.185940433506),
  (1.4, -0.00831695557921, -0.0353275897783, -0.0823045501653, 1.80170747724, 0.198292522764),
  (1.45, 0.00714652339066, -0.0294436787105, -0.0733232327065, 1.77548961591, 0.224510384094),
  (
    1.51594202899,
    0.0270430118527,
    -0.0231599631324,
    -0.0624664898593,
    1.73804644183,
    0.261953558171,
  ),
  (
    1.58188405797,
    0.0462752222731,
    -0.0182241422939,
    -0.0527695325009,
    1.69779892855,
    0.30220107145,
  ),
  (
    1.64782608696,
    0.0647631982805,
    -0.0143473042433,
    -0.0442282101762,
    1.65539027766,
    0.344609722344,
  ),
  (
    1.71376811594,
    0.082450979081,
    -0.0113018953429,
    -0.0368012976597,
    1.61157319453,
    0.388426805472,
  ),
  (
    1.77971014493,
    0.0993022955028,
    -0.0089090437726,
    -0.0304197503905,
    1.56714783794,
    0.432852162062,
  ),
  (
    1.84565217391,
    0.115297126157,
    -0.00702830555667,
    -0.0249956143654,
    1.52289773679,
    0.477102263214,
  ),
  (1.9115942029, 0.130428938698, -0.00554945978974, -0.020430129755, 1.47953421836, 0.520465781644),
  (
    1.97753623188,
    0.144702412877,
    -0.00438600966875,
    -0.0166206483383,
    1.43765671428,
    0.562343285721,
  ),
  (2, 0.14937104485, -0.00404913398153, -0.0154774130585, 1.42381726988, 0.576182730119),
  (
    2.04347826087,
    0.158131470755,
    -0.00347007224105,
    -0.0134661253541,
    1.39773179038,
    0.602268209622,
  ),
  (
    2.10942028986,
    0.170737496078,
    -0.00274837583053,
    -0.0108711154627,
    1.36008957314,
    0.639910426861,
  ),
  (
    2.17536231884,
    0.182547685276,
    -0.00217912757237,
    -0.0087483592458,
    1.32493353028,
    0.675066469721,
  ),
  (
    2.24130434783,
    0.193593521384,
    -0.00172955830986,
    -0.00702016021337,
    1.29235857188,
    0.707641428116,
  ),
  (
    2.30724637681,
    0.203909392189,
    -0.00137399328148,
    -0.00561881103006,
    1.26237280241,
    0.737627197591,
  ),
  (
    2.3731884058,
    0.213531384651,
    -0.00109233182523,
    -0.00448633692002,
    1.23491935861,
    0.765080641392,
  ),
  (
    2.43913043478,
    0.222496283021,
    -0.000868847014815,
    -0.00357379849258,
    1.20989606537,
    0.790103934632,
  ),
  (
    2.50507246377,
    0.230840783892,
    -0.000691237268374,
    -0.00284035177735,
    1.18717178323,
    0.812828216772,
  ),
  (
    2.57101449275,
    0.238600923828,
    -0.000549877680824,
    -0.00225221337773,
    1.16659916029,
    0.833400839709,
  ),
  (
    2.63695652174,
    0.245811699019,
    -0.000437230394414,
    -0.00178163209634,
    1.14802402639,
    0.851975973609,
  ),
  (
    2.70289855072,
    0.252506844722,
    -0.000347381866822,
    -0.00140592966136,
    1.13129193583,
    0.868708064167,
  ),
  (
    2.76884057971,
    0.258718736328,
    -0.000275681311676,
    -0.00110664368613,
    1.11625245338,
    0.883747546618,
  ),
  (
    2.8347826087,
    0.264478373541,
    -0.000218459522425,
    -0.00086878523768,
    1.10276175623,
    0.897238243766,
  ),
  (
    2.90072463768,
    0.269815413209,
    -0.000172811195852,
    -0.000680209963068,
    1.09068404591,
    0.909315954087,
  ),
  (
    2.96666666667,
    0.274758223075,
    -0.000136427043853,
    -0.000531093937819,
    1.07989216426,
    0.920107835739,
  ),
  (
    3.03260869565,
    0.279333936708,
    -0.000107464611371,
    -0.000413501649085,
    1.07026770883,
    0.929732291173,
  ),
  (
    3.09855072464,
    0.283568497575,
    -8.4448922455e-05,
    -0.000321032449378,
    1.0617008563,
    0.938299143702,
  ),
  (
    3.16449275362,
    0.287486686895,
    -6.61959270387e-05,
    -0.000248532358111,
    1.05409003275,
    0.945909967255,
  ),
  (
    3.23043478261,
    0.291112134944,
    -5.17532639933e-05,
    -0.000191859480446,
    1.04734151682,
    0.952658483185,
  ),
  (
    3.29637681159,
    0.294467318884,
    -4.03541242848e-05,
    -0.000147693038275,
    1.04136902466,
    0.958630975342,
  ),
  (
    3.36231884058,
    0.297573551936,
    -3.13810205745e-05,
    -0.000113377745033,
    1.03609330071,
    0.96390669929,
  ),
  (
    3.42826086957,
    0.30045096929,
    -2.43370756893e-05,
    -8.67968291719e-05,
    1.03144172334,
    0.968558276655,
  ),
  (
    3.49420289855,
    0.303118515747,
    -1.88230626545e-05,
    -6.62683449506e-05,
    1.02734792616,
    0.972652073844,
  ),
  (
    3.56014492754,
    0.305593939151,
    -1.45188949721e-05,
    -5.04604915261e-05,
    1.02375143203,
    0.976248567966,
  ),
  (
    3.62608695652,
    0.307893792475,
    -1.11686080436e-05,
    -3.83225146e-05,
    1.02059729635,
    0.979402703649,
  ),
  (
    3.69202898551,
    0.310033446176,
    -8.56811926853e-06,
    -2.90284271338e-05,
    1.01783575625,
    0.982164243746,
  ),
  (
    3.75797101449,
    0.312027111321,
    -6.55522950277e-06,
    -2.19312975731e-05,
    1.01542188442,
    0.984578115583,
  ),
  (
    3.82391304348,
    0.313887873077,
    -5.00145235627e-06,
    -1.65262526624e-05,
    1.01331524699,
    0.986684753009,
  ),
  (
    3.88985507246,
    0.315627733443,
    -3.80534561506e-06,
    -1.2420657165e-05,
    1.0114795667,
    0.988520433303,
  ),
  (
    3.95579710145,
    0.317257661726,
    -2.88708248353e-06,
    -9.3101873222e-06,
    1.00988239286,
    0.990117607143,
  ),
  (4, 0.318293725075, -2.39529333279e-06, -7.66272909436e-06, 1.00893072605, 0.991069273952),
  (
    4.02173913043,
    0.318787650964,
    -2.18404742425e-06,
    -6.95972471076e-06,
    1.00849478062,
    0.991505219382,
  ),
  (
    4.08768115942,
    0.320226778517,
    -1.64727770258e-06,
    -5.18817324646e-06,
    1.00729098174,
    0.992709018261,
  ),
  (
    4.15362318841,
    0.321583269054,
    -1.23860079593e-06,
    -3.85645158874e-06,
    1.0062481492,
    0.993751850795,
  ),
  (
    4.21956521739,
    0.322864558394,
    -9.28341905793e-07,
    -2.8580409186e-06,
    1.00534605757,
    0.994653942432,
  ),
  (
    4.28550724638,
    0.324077356831,
    -6.93496123749e-07,
    -2.1115771186e-06,
    1.00456684052,
    0.995433159485,
  ),
  (
    4.35144927536,
    0.325227710846,
    -5.16277261386e-07,
    -1.55506922028e-06,
    1.00389474665,
    0.996105253351,
  ),
  (
    4.41739130435,
    0.326321062341,
    -3.82970312574e-07,
    -1.14140439633e-06,
    1.003315914,
    0.996684086004,
  ),
  (
    4.48333333333,
    0.327362304774,
    -2.83027378201e-07,
    -8.34865520494e-07,
    1.00281816331,
    0.997181836687,
  ),
  (
    4.54927536232,
    0.328355835772,
    -2.08357815668e-07,
    -6.08441864225e-07,
    1.00239080987,
    0.997609190126,
  ),
  (
    4.6152173913,
    0.329305605982,
    -1.52772607565e-07,
    -4.41758368219e-07,
    1.00202449309,
    0.997975506913,
  ),
  (
    4.68115942029,
    0.33021516407,
    -1.11550679693e-07,
    -3.19485472411e-07,
    1.00171102307,
    0.998288976929,
  ),
  (
    4.74710144928,
    0.331087697895,
    -8.11012828006e-08,
    -2.30120996481e-07,
    1.00144324314,
    0.998556756864,
  ),
  (
    4.81304347826,
    0.331926071968,
    -5.87017984222e-08,
    -1.65059163559e-07,
    1.001214907,
    0.998785093004,
  ),
  (
    4.87898550725,
    0.33273286138,
    -4.2294592606e-08,
    -1.17880669337e-07,
    1.00102056951,
    0.99897943049,
  ),
  (
    4.94492753623,
    0.333510382398,
    -3.03299869664e-08,
    -8.38124754043e-08,
    1.00085548971,
    0.999144510286,
  ),
  (
    5.01086956522,
    0.334260720001,
    -2.16451532253e-08,
    -5.93176670005e-08,
    1.00071554497,
    0.999284455035,
  ),
  (
    5.0768115942,
    0.334985752577,
    -1.53709391881e-08,
    -4.17847538792e-08,
    1.00059715504,
    0.999402844962,
  ),
  (
    5.14275362319,
    0.33568717405,
    -1.08603811499e-08,
    -2.92928868939e-08,
    1.00049721512,
    0.999502784884,
  ),
  (
    5.20869565217,
    0.336366513681,
    -7.6339909949e-09,
    -2.0434893111e-08,
    1.00041303669,
    0.99958696331,
  ),
  (
    5.27463768116,
    0.337025153761,
    -5.33802435587e-09,
    -1.418427098e-08,
    1.00034229546,
    0.999657704541,
  ),
  (
    5.34057971014,
    0.33766434542,
    -3.71274955224e-09,
    -9.79552916558e-09,
    1.00028298543,
    0.999717014571,
  ),
  (
    5.40652173913,
    0.33828522274,
    -2.56840892998e-09,
    -6.72976774307e-09,
    1.00023337849,
    0.999766621513,
  ),
  (
    5.47246376812,
    0.338888815358,
    -1.76708137012e-09,
    -4.5992989417e-09,
    1.00019198881,
    0.999808011194,
  ),
  (
    5.5384057971,
    0.339476059712,
    -1.20905563339e-09,
    -3.12660974888e-09,
    1.00015754151,
    0.999842458486,
  ),
  (
    5.60434782609,
    0.340047809076,
    -8.22640067177e-10,
    -2.11407413797e-09,
    1.00012894513,
    0.99987105487,
  ),
  (
    5.67028985507,
    0.340604842509,
    -5.56579116129e-10,
    -1.42170086814e-09,
    1.00010526733,
    0.999894732673,
  ),
  (
    5.73623188406,
    0.341147872836,
    -3.74436814887e-10,
    -9.50860168381e-10,
    1.00008571364,
    0.999914286363,
  ),
  (
    5.80217391304,
    0.341677553758,
    -2.50467202534e-10,
    -6.32452090699e-10,
    1.00006960876,
    0.999930391239,
  ),
  (
    5.86811594203,
    0.342194486184,
    -1.66581748395e-10,
    -4.18335255326e-10,
    1.00005638018,
    0.999943619819,
  ),
  (
    5.93405797101,
    0.342699223865,
    -1.1015377499e-10,
    -2.75165779051e-10,
    1.00004554382,
    0.999954456181,
  ),
  (6, 0.343192278403, -7.24198478963e-11, -1.79980030879e-10, 1.00003669151, 0.999963308492),
)

#let energy_point(distance, energy) = (
  88 + (distance - 0.25) / 5.75 * 510,
  -570 - (0.4 - energy) / 0.64 * 180,
)
#let occupation_point(distance, occupation) = (
  764 + (distance - 0.25) / 5.75 * 270,
  -570 - (2 - occupation) / 2 * 180,
)

#let probability_map(left, top, correlated: false) = {
  let cell_size = 55
  for (col_idx, atom) in ([A], [B]).enumerate() {
    symbol(left + col_idx * cell_size + cell_size / 2, top - 17, atom, size: 16pt)
    symbol(left - 17, top + col_idx * cell_size + cell_size / 2, atom, size: 16pt)
  }
  for row_idx in range(2) {
    for col_idx in range(2) {
      let same_atom = row_idx == col_idx
      let cell_fill = if same_atom {
        if correlated { rgb("#F4F5F7") } else { orange.lighten(72%) }
      } else { blue.lighten(if correlated { 53% } else { 78% }) }
      rect(
        (left + col_idx * cell_size, -top - row_idx * cell_size),
        (left + (col_idx + 1) * cell_size - 3, -top - (row_idx + 1) * cell_size + 3),
        radius: 5,
        fill: cell_fill,
        stroke: none,
      )
      symbol(
        left + col_idx * cell_size + (cell_size - 3) / 2,
        top + row_idx * cell_size + (cell_size - 3) / 2,
        if correlated {
          if same_atom { [$0$] } else { [$1/2$] }
        } else { [$1/4$] },
        size: 23pt,
        color: if same_atom { orange } else { ink },
      )
    }
  }
}

#canvas(length: 1pt, {
  rect((0, 0), (1100, -1424), fill: white, stroke: none)
  rect((0, 0), (1100, -8), fill: teal, stroke: none)
  label(30, 20, 1040, [Why breaking H₂ is hard], size: 37pt, weight: "bold")
  label(
    32,
    65,
    1036,
    [Bond breaking is central to chemical reactions; H₂ is the simplest test of whether DFT gets the electron rearrangement right.],
    size: 16pt,
    color: muted,
  )
  label(
    30,
    98,
    1040,
    [1  Stretch the bond: a second configuration becomes essential],
    size: 19pt,
    weight: "bold",
  )

  // === Bond stretching storyboard ===
  for (left, title, caption, fill) in (
    (28, [BONDED], [Mostly two electrons in the bonding orbital], pale_blue),
    (386, [STRETCHED], [Antibonding-pair configuration gains weight], pale_orange),
    (744, [SEPARATED], [One electron on each neutral H atom], pale_teal),
  ) {
    panel(left, 126, 328, 144, fill)
    label(left + 13, 138, 302, title, size: 16pt, weight: "bold", centered: true)
    label(left + 13, 245, 302, caption, size: 12.5pt, centered: true)
  }
  orbital_cloud(192, 198, 88, 35)
  nucleus(168, 198)
  nucleus(216, 198)
  orbital_cloud(510, 198, 53, 35)
  orbital_cloud(590, 198, 53, 35)
  nucleus(510, 198)
  nucleus(590, 198)
  orbital_cloud(830, 198, 35, 35)
  orbital_cloud(986, 198, 35, 35)
  nucleus(830, 198)
  nucleus(986, 198)
  connect((361, -198), (381, -198), color: teal)
  connect((719, -198), (739, -198), color: teal)
  label(785, 232, 90, [H (A)], size: 12pt, centered: true)
  label(941, 232, 90, [H (B)], size: 12pt, centered: true)

  // === Decode the orbital names through phase and symmetry ===
  panel(28, 280, 686, 156, rgb("#F5F7FA"))
  panel(744, 280, 328, 156, rgb("#F5F7FA"))
  label(42, 289, 300, [$sigma_g$: bonding], size: 17pt, color: blue, weight: "bold")
  label(
    400,
    289,
    300,
    [$sigma_u$: antibonding (also $sigma_u^*$)],
    size: 17pt,
    color: orange,
    weight: "bold",
  )
  label(758, 289, 300, [READ THE SYMBOLS], size: 14pt, weight: "bold")
  orbital_cloud(106, 340, 61, 22)
  symbol(78, 340, [$+$], size: 21pt, color: blue)
  symbol(134, 340, [$+$], size: 21pt, color: blue)
  orbital_cloud(446, 340, 27, 22)
  orbital_cloud(504, 340, 27, 22, color: orange)
  symbol(446, 340, [$+$], size: 21pt, color: blue)
  symbol(504, 340, [$-$], size: 21pt, color: orange)
  line((475, -315), (475, -364), stroke: (paint: muted, thickness: 0.8pt, dash: "dashed"))
  label(424, 367, 100, [node: zero amplitude], size: 9pt, color: muted, centered: true)
  label(
    182,
    320,
    162,
    [*g = gerade (even)*\ Invert through midpoint:\ orbital keeps its sign.],
    size: 11.5pt,
  )
  label(
    540,
    320,
    162,
    [*u = ungerade (odd)*\ Invert through midpoint:\ orbital flips its sign.],
    size: 11.5pt,
  )
  label(42, 389, 300, [1s waves add → density builds between nuclei.], size: 11.5pt, color: blue)
  label(400, 389, 300, [1s waves subtract → a node between nuclei.], size: 11.5pt, color: orange)
  label(
    42,
    417,
    658,
    [+/− show wavefunction sign (phase), not electric charge. Inversion maps each point through the bond center.],
    size: 9.5pt,
    color: muted,
  )
  label(
    758,
    317,
    298,
    [$sigma$: unchanged by rotation around the H–H axis.\ $sigma_g^2$: two opposite-spin electrons in $sigma_g$.\ Configuration = an orbital-occupation pattern.\ g/u label symmetry, not bonding in general; an asterisk marks antibonding.],
    size: 11.5pt,
  )

  // === Calculated dissociation and natural occupations ===
  label(
    30,
    458,
    1040,
    [2  Watch the energy and the real-electron occupations],
    size: 19pt,
    weight: "bold",
  )
  label(65, 490, 583, [Energy relative to two separated H atoms], size: 16pt, weight: "bold")
  for (start_x, color, name, description, dashed) in (
    (81, orange, [RHF], [Restricted\ Hartree-Fock], false),
    (257, purple, [UHF], [Unrestricted\ Hartree-Fock], true),
    (433, teal, [FCI], [Full configuration\ interaction], false),
  ) {
    line((start_x, -521), (start_x + 25, -521), stroke: (
      paint: color,
      thickness: 2.4pt,
      dash: if dashed { "dashed" } else { "solid" },
    ))
    // Anchor actual glyph bounds to the same centerline as the line sample.
    content(
      (start_x + 34, -521),
      text(
        size: 12pt,
        fill: color,
        weight: "bold",
        top-edge: "bounds",
        bottom-edge: "bounds",
        name,
      ),
      anchor: "west",
      padding: 0pt,
    )
    label(start_x + 34, 533, 142, description, size: 10.5pt, color: color)
  }
  for energy in (-0.2, 0, 0.2, 0.4) {
    let point = energy_point(0.25, energy)
    line(point, energy_point(6, energy), stroke: (
      paint: if energy == 0 { muted } else { rgb("#E7EBF1") },
      thickness: if energy == 0 { 1pt } else { 0.65pt },
      dash: "dashed",
    ))
    label(43, -point.at(1) - 8, 37, [#energy], size: 11pt, color: muted)
  }
  line(
    energy_point(0.25, 0.4),
    energy_point(0.25, -0.24),
    energy_point(6, -0.24),
    stroke: 0.8pt + muted,
  )
  for distance in (1, 2, 3, 4, 5, 6) {
    let point = energy_point(distance, -0.24)
    line(point, (point.at(0), point.at(1) - 4), stroke: 0.7pt + muted)
    label(
      point.at(0) - 12,
      -point.at(1) + 8,
      24,
      [#distance],
      size: 11pt,
      color: muted,
      centered: true,
    )
  }
  // Draw FCI last so the correct asymptote remains visible where UHF merges with it.
  for (column, color, dashed) in ((1, orange, false), (2, purple, true), (3, teal, false)) {
    line(..curve_data.map(row => energy_point(row.at(0), row.at(column))), stroke: (
      paint: color,
      thickness: 2.6pt,
      dash: if dashed { "dashed" } else { "solid" },
    ))
  }
  label(35, 544, 40, [$E_h$], size: 12pt, color: muted)
  label(603, 672.5, 62, [2 H], size: 12pt, color: muted)
  label(391, 576, 210, [RHF: wrong dissociation limit], size: 11.5pt, color: orange)
  label(
    238,
    722,
    360,
    [Static correlation: several configurations are needed],
    size: 11.5pt,
    color: teal,
  )
  label(240, 776, 240, [H–H distance $R$ (angstrom)], size: 12pt, color: muted, centered: true)

  label(
    726,
    490,
    329,
    [Interacting natural occupations],
    size: 16pt,
    weight: "bold",
    centered: true,
  )
  label(
    720,
    516,
    340,
    [Average electrons per natural orbital; together they sum to 2.],
    size: 10.5pt,
    color: muted,
    centered: true,
  )
  for occupation in (0, 1, 2) {
    let point = occupation_point(0.25, occupation)
    line(point, occupation_point(6, occupation), stroke: (
      paint: rgb("#DCE3EC"),
      thickness: 0.7pt,
      dash: "dashed",
    ))
    label(738, -point.at(1) - 8, 20, [#occupation], size: 11pt, color: muted)
  }
  line(
    occupation_point(0.25, 2),
    occupation_point(0.25, 0),
    occupation_point(6, 0),
    stroke: 0.8pt + muted,
  )
  for (column, color) in ((4, blue), (5, orange)) {
    line(
      ..curve_data.map(row => occupation_point(row.at(0), row.at(column))),
      stroke: 2.6pt + color,
    )
  }
  label(894, 601, 133, [bonding $sigma_g$], size: 12pt, color: blue)
  label(889, 688, 155, [antibonding $sigma_u$], size: 12pt, color: orange)
  for distance in (1, 3, 6) {
    let point = occupation_point(distance, 0)
    label(point.at(0) - 13, 758, 26, [#distance], size: 11pt, color: muted, centered: true)
  }
  label(838, 776, 146, [$R$ (angstrom)], size: 12pt, color: muted, centered: true)
  label(
    727,
    544,
    329,
    [Bonding/antibonding: $(2, 0)$ → $(1, 1)$.],
    size: 12pt,
    color: ink,
    centered: true,
  )
  label(
    88,
    800,
    968,
    [Basis = allowed orbital building blocks; STO-3G uses one 1s (lowest atomic orbital) per H. FCI mixes all allowed configurations and is *exact in this basis*.],
    size: 10pt,
    color: muted,
    centered: true,
  )

  // === Pair probabilities expose the error in the separated-atom limit ===
  label(
    30,
    831,
    1040,
    [3  At infinite separation: correct average density, wrong pair probabilities],
    size: 19pt,
    weight: "bold",
  )
  label(
    46,
    864,
    266,
    [Restricted $sigma_g^2$ reference],
    size: 16pt,
    color: orange,
    weight: "bold",
    centered: true,
  )
  label(
    371,
    864,
    266,
    [Correlated singlet],
    size: 16pt,
    color: teal,
    weight: "bold",
    centered: true,
  )
  label(96, 923, 180, [spin-up electron], size: 11pt, color: muted, centered: true)
  label(420, 923, 180, [spin-up electron], size: 11pt, color: muted, centered: true)
  probability_map(125, 959)
  probability_map(450, 959, correlated: true)
  label(34, 994, 63, [spin-down\ electron], size: 10.5pt, color: muted, centered: true)
  label(359, 994, 63, [spin-down\ electron], size: 10.5pt, color: muted, centered: true)
  connect((278, -1014), (342, -1014), color: teal)
  label(272, 971, 80, [correlate], size: 11.5pt, color: teal, centered: true)
  label(
    62,
    1081,
    255,
    [50% ionic weight],
    size: 17pt,
    color: orange,
    weight: "bold",
    centered: true,
  )
  label(387, 1081, 255, [0% ionic weight], size: 17pt, color: teal, weight: "bold", centered: true)
  label(
    63,
    1110,
    577,
    [Ionic weight = chance both electrons are on the same atom.\ Orange diagonal: charged $"H"^- + "H"^+$; blue off-diagonal: neutral $"H" + "H"$.],
    size: 11.5pt,
    color: muted,
    centered: true,
  )

  panel(690, 862, 382, 278, rgb("#F2F6FC"))
  label(
    708,
    912,
    348,
    [A/B: 1s orbitals on atoms A/B; (1)/(2): electron labels.],
    size: 10.5pt,
    color: muted,
    centered: true,
  )
  label(
    708,
    1075,
    348,
    [$Psi_S$: the pair’s spatial wave; $abs(Psi_S)^2$: probability density.],
    size: 10.5pt,
    color: muted,
    centered: true,
  )
  label(
    705,
    877,
    352,
    [Cancel the ionic amplitudes],
    size: 19pt,
    color: blue,
    weight: "bold",
    centered: true,
  )
  label(
    708,
    931,
    348,
    [$sigma_g = (A + B) / sqrt(2) quad sigma_u = (A - B) / sqrt(2)$],
    size: 19pt,
    centered: true,
  )
  label(
    700,
    984,
    362,
    [$Psi_S = frac(1, sqrt(2)) (sigma_g (1) sigma_g (2) - sigma_u (1) sigma_u (2))$],
    size: 18pt,
    color: blue,
    centered: true,
  )
  label(
    708,
    1039,
    348,
    [$= frac(1, sqrt(2)) (A(1) B(2) + B(1) A(2))$],
    size: 20pt,
    color: teal,
    centered: true,
  )
  label(
    709,
    1101,
    347,
    [Superposition: add waves first, then square to get probabilities.\ Same-atom terms cancel; only one-on-each-atom terms survive.],
    size: 11.5pt,
    color: muted,
    centered: true,
  )

  label(
    46,
    885,
    266,
    [Restricted: both spins share one spatial orbital.],
    size: 10.5pt,
    color: muted,
    centered: true,
  )
  label(
    371,
    885,
    266,
    [Singlet: spins combine to zero. Measured along any shared axis, they give opposite results.],
    size: 10.5pt,
    color: teal,
    centered: true,
  )

  // === The KS distinction is the central DFT takeaway ===
  label(
    30,
    1158,
    1040,
    [4  What this means for density-functional theory (DFT)],
    size: 19pt,
    weight: "bold",
  )
  for (left, fill) in ((28, pale_blue), (386, pale_orange), (744, pale_teal)) {
    panel(left, 1188, 328, 144, fill)
  }
  label(
    43,
    1201,
    298,
    [KOHN–SHAM (KS): ONE ORBITAL],
    size: 13pt,
    color: blue,
    weight: "bold",
    centered: true,
  )
  label(
    44,
    1264,
    296,
    [$n$: electron density · $phi_"KS"$: model orbital],
    size: 10.5pt,
    color: blue,
    centered: true,
  )
  symbol(192, 1244, [$phi_"KS" = sqrt(n / 2)$], size: 24pt, color: blue)
  label(
    44,
    1284,
    296,
    [Its occupation stays 2. Exact XC supplies correlation; this model electron pair is not the real state.],
    size: 12pt,
    centered: true,
  )

  label(
    401,
    1201,
    298,
    [LOWER ENERGY, WRONG SPIN STATE],
    size: 12.5pt,
    color: orange,
    weight: "bold",
    centered: true,
  )
  circle((510, -1244), radius: 23, fill: white, stroke: 0.8pt + orange.lighten(65%))
  circle((590, -1244), radius: 23, fill: white, stroke: 0.8pt + orange.lighten(65%))
  electron(510, 1244, "up")
  electron(590, 1244, "down")
  label(
    402,
    1284,
    296,
    [UHF lets up/down spins use different orbitals.\ It reaches two neutral H atoms, but the spins no longer form a pure singlet.],
    size: 12pt,
    centered: true,
  )

  label(
    759,
    1201,
    298,
    [THE FUNCTIONAL MUST DO THE WORK],
    size: 12.5pt,
    color: teal,
    weight: "bold",
    centered: true,
  )
  label(
    760,
    1264,
    296,
    [Exchange–correlation (XC) energy functional],
    size: 10.5pt,
    color: teal,
    centered: true,
  )
  symbol(908, 1244, [$E_"xc" [n]$], size: 27pt, color: teal)
  label(
    760,
    1284,
    296,
    [A functional maps density to energy. Common approximations can miss static correlation; exact DFT need not.],
    size: 12pt,
    centered: true,
  )

  label(
    30,
    1350,
    1040,
    [H₂ exposes a central DFT challenge: the density can look right while the energy is wrong unless XC captures how electrons avoid each other.],
    size: 13pt,
    color: teal,
    centered: true,
  )
  label(
    30,
    1380,
    1040,
    [Fixed nuclei; curves include nuclear repulsion. $E_h$: hartree, the atomic energy unit. Natural occupations: eigenvalues of the one-electron density matrix. Maps/formula: nonoverlapping 1s orbitals; singlet spin factor suppressed. Clouds are schematic.],
    size: 9.5pt,
    color: muted,
    centered: true,
  )
  label(
    30,
    1404,
    1040,
    [#link("https://dft.uci.edu/pubs/FNGB05.pdf")[Fuchs et al., JCP 122, 094116 (2005)] · #link("https://dft.uci.edu/teaching/lausanne/ABCDFT.pdf")[Burke: The ABC of DFT, §§4, 7, 11, 13] · #link("https://doi.org/10.1063/1.1672392")[Hehre et al., STO-3G (1969)] · #link("https://ocw.mit.edu/courses/5-61-physical-chemistry-fall-2017/resources/mit5_61f17_lec25/")[MIT: orbital symmetry] · #link("https://web.mit.edu/2.111/www/notes09/spring.pdf")[MIT: singlet spins]],
    size: 9pt,
    color: muted,
    centered: true,
  )
})
