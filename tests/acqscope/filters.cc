#include "filters.h"

LPF10kHz = {-0.000005532449004426419313909437519560797,
		       -0.000004669294519640558123387431149753368,
		       -0.000004979111106134555157570146383116949,
		       -0.000003684416065561423998629816609073906,
		       -0.000000367625851454420736728358459072252,
		       0.000004936816972911814926060214414604843,
		       0.000011573598517439249316624688690424705,
		       0.000018214390849313477356141016683110934,
		     0.000022995644833457171639888583225541652,
		       0.00002384955576603744748908492168126827 ,
		       0.00001901113335083723704832699141764607 ,
		       0.000007597101354603687272445261546849338,
		       -0.000009859594690988117738380917820517624,
		       -0.000031093939047861031453948155167665846,
		       -0.000052144349160646183904358613725449345,
		     -0.000067848389737176184838100823082385205,
		       -0.000072775647079057606872974639511397754,
		       -0.000062495964073697220513177452705377846,
		       -0.000034937156330403518482603797412622271,
		     0.000008458149613067947967929606500891992,
		     0.000062140688642163378701231690737216695,
		     0.000116695436339666987397324648956242754,
		     0.000160071040304991677252766102412806504,
		     0.000179709823885447397134873526169940305,
		     0.000165324167314119567983796144083896706,
		     0.000111787864825073918607738210351243424,
		     0.000021499405796004873611627569718329767,
		     -0.000094462201855529488378482305677152908,
		     -0.000216855307548261905465150634064741553,
		     -0.000320799085919056946748090242138573558,
		     -0.000380054173825499083064910488261034516,
		     -0.00037249075947226790474220425863904893 ,
		     -0.00028578586207983312653460594709997622 ,
		     -0.000122048553239656216041347791545490509,
		     0.000099767302988681326675682314863990996,
		     0.00034469130484752731830369598675645193 ,
		     0.000566163957515617528512552603103813453,
		     0.000713799815931947211067321035216082237,
		     0.00074337119146277862331839703102787098 ,
		     0.00062726597050217786782910778242694505 ,
		     0.000363238650303862023373951961602301708,
		     -0.000020698395495404012023104786677230038,
		     -0.000466941347003324526074297118327649514,
		     -0.000895292225026140305738087121767421195,
		     -0.001215842562831880458579236758964725595,
		     -0.001345966894306674377368437944824108854,
		     -0.001228512840251874986205460338339889859,
		     -0.000847572713991619946030664500824514107,
		     -0.000238177014679043225339402645168718209,
		     0.000513019561589332954640307882243632775,
		     0.001277540556257277838680952442018678994,
		     0.001904899013907519061961082229572639335,
		     0.002249803459969570117171766554520218051,
		     0.002202233086750114091773022906295409484,
		     0.001714654454077675985179674000846716808,
		     0.000820446819074462834267547073352488951,
		     -0.000361418747060933854154535227465316893,
		     -0.001638260931082641865680349368972201773,
		     -0.002771947088132643843838565089754411019,
		     -0.003520051949845334933464346960363400285,
		     -0.003683337217654367688746130937715861364,
		     -0.003150919074462911386586005946242039499,
		     -0.001933817569455626101185274912097611377,
		     -0.000178759442993240086697270818660854275,
		     0.001842987134068293933811255591592725978,
		     0.00377267277370379582740467228063607763 ,
		     0.005222944978790030126636345642054948257,
		     0.005849708329766671772997899125812182319,
		     0.005424526348752931742547289672984334175,
		     0.003893565159005127514213473460813474958,
		     0.001410043976016620535796075586176812067,
		     -0.001669234431331166872841675896665947221,
		     -0.004826881102045477850426280497231346089,
		     -0.007463907480068369265646666121938324068,
		     -0.009003923571770775305389555853707861388,
		     -0.009005791273902422414132651340423763031,
		     -0.00726452746272960529078099867206219642 ,
		     -0.003880229340596643566874135444777493831,
		     0.000721485474331908394757251201667713758,
		     0.005826889954458828839445327929524864885,
		     0.010529219754770235278895640362861740869,
		     0.013870778235387393878541573144502763171,
		     0.015011960872460310134623995281799579971,
		     0.013400301422814783064429988712618069258,
		     0.008910053689637256399413978158463578438,
		     0.001925171031059291684023326851615820487,
		     -0.006654186376661965808543275358033497469,
		     -0.015490208473085995827256411416783521418,
		     -0.022966059433571835157739116084485431202,
		     -0.027405853233633398202684361422143410891,
		     -0.027325750253721831084519067189830821007,
		     -0.02167875726350306300749259946769598173 ,
		     -0.01005434707638862106005017693632908049 ,
		     0.007201115621582696892100106111911372864,
		     0.028966543590481209913267690581051283516,
		     0.05343937130664210000130509570226422511 ,
		     0.078331478942246304808527668228634865955,
		     0.10114322363138236737789554808841785416 ,
		     0.119478204937657553341701088811532827094,
		     0.131354129587551271551859599640010856092,
		     0.135464711980178231787164122579270042479,
		     0.131354129587551271551859599640010856092,
		     0.119478204937657553341701088811532827094,
		     0.10114322363138236737789554808841785416 ,
		     0.078331478942246304808527668228634865955,
		     0.05343937130664210000130509570226422511 ,
		     0.028966543590481209913267690581051283516,
		     0.007201115621582696892100106111911372864,
		     -0.01005434707638862106005017693632908049 ,
		     -0.02167875726350306300749259946769598173 ,
		     -0.027325750253721831084519067189830821007,
		     -0.027405853233633398202684361422143410891,
		     -0.022966059433571835157739116084485431202,
		     -0.015490208473085995827256411416783521418,
		     -0.006654186376661965808543275358033497469,
		     0.001925171031059291684023326851615820487,
		     0.008910053689637256399413978158463578438,
		     0.013400301422814783064429988712618069258,
		     0.015011960872460310134623995281799579971,
		     0.013870778235387393878541573144502763171,
		     0.010529219754770235278895640362861740869,
		     0.005826889954458828839445327929524864885,
		     0.000721485474331908394757251201667713758,
		     -0.003880229340596643566874135444777493831,
		     -0.00726452746272960529078099867206219642 ,
		     -0.009005791273902422414132651340423763031,
		     -0.009003923571770775305389555853707861388,
		     -0.007463907480068369265646666121938324068,
		     -0.004826881102045477850426280497231346089,
		     -0.001669234431331166872841675896665947221,
		     0.001410043976016620535796075586176812067,
		     0.003893565159005127514213473460813474958,
		     0.005424526348752931742547289672984334175,
		     0.005849708329766671772997899125812182319,
		     0.005222944978790030126636345642054948257,
		     0.00377267277370379582740467228063607763 ,
		     0.001842987134068293933811255591592725978,
		     -0.000178759442993240086697270818660854275,
		     -0.001933817569455626101185274912097611377,
		     -0.003150919074462911386586005946242039499,
		     -0.003683337217654367688746130937715861364,
		     -0.003520051949845334933464346960363400285,
		     -0.002771947088132643843838565089754411019,
		     -0.001638260931082641865680349368972201773,
		     -0.000361418747060933854154535227465316893,
		     0.000820446819074462834267547073352488951,
		     0.001714654454077675985179674000846716808,
		     0.002202233086750114091773022906295409484,
		     0.002249803459969570117171766554520218051,
		     0.001904899013907519061961082229572639335,
		     0.001277540556257277838680952442018678994,
		     0.000513019561589332954640307882243632775,
		     -0.000238177014679043225339402645168718209,
		     -0.000847572713991619946030664500824514107,
		     -0.001228512840251874986205460338339889859,
		     -0.001345966894306674377368437944824108854,
		     -0.001215842562831880458579236758964725595,
		     -0.000895292225026140305738087121767421195,
		     -0.000466941347003324526074297118327649514,
		     -0.000020698395495404012023104786677230038,
		     0.000363238650303862023373951961602301708,
		     0.00062726597050217786782910778242694505 ,
		     0.00074337119146277862331839703102787098 ,
		     0.000713799815931947211067321035216082237,
		     0.000566163957515617528512552603103813453,
		     0.00034469130484752731830369598675645193 ,
		     0.000099767302988681326675682314863990996,
		     -0.000122048553239656216041347791545490509,
		     -0.00028578586207983312653460594709997622 ,
		     -0.00037249075947226790474220425863904893 ,
		     -0.000380054173825499083064910488261034516,
		     -0.000320799085919056946748090242138573558,
		     -0.000216855307548261905465150634064741553,
		     -0.000094462201855529488378482305677152908,
		     0.000021499405796004873611627569718329767,
		     0.000111787864825073918607738210351243424,
		     0.000165324167314119567983796144083896706,
		     0.000179709823885447397134873526169940305,
		     0.000160071040304991677252766102412806504,
		     0.000116695436339666987397324648956242754,
		     0.000062140688642163378701231690737216695,
		     0.000008458149613067947967929606500891992,
		     -0.000034937156330403518482603797412622271,
		     -0.000062495964073697220513177452705377846,
		     -0.000072775647079057606872974639511397754,
		     -0.000067848389737176184838100823082385205,
		     -0.000052144349160646183904358613725449345,
		     -0.000031093939047861031453948155167665846,
		     -0.000009859594690988117738380917820517624,
		     0.000007597101354603687272445261546849338,
		     0.00001901113335083723704832699141764607 ,
		     0.00002384955576603744748908492168126827 ,
		     0.000022995644833457171639888583225541652,
		     0.000018214390849313477356141016683110934,
		     0.000011573598517439249316624688690424705,
		     0.000004936816972911814926060214414604843,
		     -0.000000367625851454420736728358459072252,
		     -0.000003684416065561423998629816609073906,
		     -0.000004979111106134555157570146383116949,
		     -0.000004669294519640558123387431149753368,
		     -0.000005532449004426419313909437519560797};
