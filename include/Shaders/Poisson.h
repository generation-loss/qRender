/*
Copyright (c) 2022 Generation Loss Interactive

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#ifndef __Q_RENDER_SHADER_POISSON_H__
#define __Q_RENDER_SHADER_POISSON_H__

#define POISSON_SAMPLE_COUNT_6 6

constant float2 POISSON_SAMPLES_6[POISSON_SAMPLE_COUNT_6] =
{
	float2( 0.0f, 0.0f ),
	float2( -0.8503909101662536f, 0.5216322311907754f ),
	float2( 0.9773149620572006f, 0.18547433748337194f ),
	float2( -0.8197280622217029f, -0.5541924081475489f ),
	float2( 0.43665087132585095f, -0.8580195913177826f ),
	float2( 0.3060664346907122f, 0.9074246336242799f ),
};

#define POISSON_SAMPLE_COUNT_12 12

constant float2 POISSON_SAMPLES_12[POISSON_SAMPLE_COUNT_12] =
{
	float2( 0.0f, 0.0f ),
	float2( -0.9958408850717281f, -0.02475396577372085f ),
	float2( 0.2794678415297609f, 0.9586857373845129f ),
	float2( 0.9794630855150637f, 0.14443091536819833f ),
	float2( 0.22100697295562058f, -0.9356085892398809f ),
	float2( -0.5163937861923966f, 0.7642647076260292f ),
	float2( -0.5637276845800012f, -0.7068967753078019f ),
	float2( 0.767426315713646f, -0.38515564915124595f ),
	float2( 0.712825664652639f, 0.6210783533876735f ),
	float2( -0.0447153384775488f, 0.5179931999736773f ),
	float2( 0.25775795278948394f, -0.42212660795940116f ),
	float2( -0.48592750343479274f, -0.11660812664395491f ),
};

#define POISSON_SAMPLE_COUNT_24 24

constant float2 POISSON_SAMPLES_24[POISSON_SAMPLE_COUNT_24] =
{
	float2( 0.0f, 0.0f ),
	float2( 0.9817910268775427f, 0.18462206910818735f ),
	float2( -0.9606304303889083f, -0.2710963035224922f ),
	float2( -0.12082904230972134f, 0.9837625606817292f ),
	float2( 0.3129284047361008f, -0.8946933993126159f ),
	float2( -0.4618510751897096f, -0.8363736979183573f ),
	float2( -0.8368016805974327f, 0.4937408003754142f ),
	float2( 0.47078852166943413f, 0.6554577162355695f ),
	float2( 0.8663712630565286f, -0.4537215349928142f ),
	float2( -0.4354596171473398f, -0.32499207403299013f ),
	float2( 0.48293136199757547f, -0.10408617572391123f ),
	float2( 0.014349756387259225f, -0.4987857336953159f ),
	float2( -0.3538366422591102f, 0.3467127769318546f ),
	float2( -0.7004354806013192f, 0.06313191544055655f ),
	float2( -0.015957538418675477f, 0.5272660469086846f ),
	float2( 0.5020709172343972f, -0.4910075724194243f ),
	float2( -0.49535587513262497f, 0.8084867754509258f ),
	float2( 0.8111512557814242f, 0.5445102510222145f ),
	float2( -0.7415808504695657f, -0.5363148990809732f ),
	float2( -0.06177975889471563f, -0.9969235969658512f ),
	float2( 0.34698342083637795f, 0.2503430150278852f ),
	float2( 0.23584475343656344f, -0.2759338732551335f ),
	float2( 0.8208429215902104f, -0.1418898003474439f ),
	float2( -0.4005182693734717f, 0.03370690275567537f ),
};

#define POISSON_SAMPLE_COUNT_32 32

constant float2 POISSON_SAMPLES_32[POISSON_SAMPLE_COUNT_32] =
{
	float2( 0.0f, 0.0f ),
	float2( -0.9692122411817077f, 0.22488715412532662f ),
	float2( -0.239698886042583f, 0.9609407284648254f ),
	float2( -0.07611106189401852f, -0.9912104097104207f ),
	float2( 0.6919400381273018f, 0.6907782055459176f ),
	float2( 0.9254857394412316f, -0.3174227692176174f ),
	float2( -0.6755919090504013f, -0.6374149472127354f ),
	float2( 0.3343299054157918f, -0.5351080651126303f ),
	float2( -0.4679538080810698f, 0.43136038036841917f ),
	float2( 0.5844913260428775f, 0.13067010539691812f ),
	float2( -0.46131295228717795f, -0.13628757207173334f ),
	float2( 0.17182216941975925f, 0.5967424803999997f ),
	float2( -0.2501053922430013f, -0.5700520500868527f ),
	float2( -0.9318420034002008f, -0.24244248074901809f ),
	float2( -0.5732950248708517f, 0.8052132814312786f ),
	float2( 0.9576550594252022f, 0.05216003185843631f ),
	float2( 0.700555480562416f, -0.6665859342124041f ),
	float2( 0.2506686683568452f, 0.9575066507297362f ),
	float2( 0.28922878919455053f, -0.8970706223001347f ),
	float2( 0.31893240511728455f, -0.1256681696479681f ),
	float2( -0.018233208066951445f, -0.32106148358816294f ),
	float2( 0.23892207399429552f, 0.2630408393749255f ),
	float2( 0.834909579411788f, 0.3874758179211381f ),
	float2( -0.10145867130446096f, 0.3493289942907863f ),
	float2( 0.5738840950653885f, -0.3195215831336705f ),
	float2( 0.04356993961360554f, -0.722828200623066f ),
	float2( -0.6614619497056167f, 0.17970640584776393f ),
	float2( -0.7659383051362902f, 0.4953851723806516f ),
	float2( -0.25099536817585977f, 0.6598265507355445f ),
	float2( -0.35031476976125564f, 0.17320340824646507f ),
	float2( -0.3738884407280187f, -0.9078600752385535f ),
	float2( 0.47934847126643604f, 0.4693171480244319f ),
};

#define POISSON_SAMPLE_COUNT_64 64

constant float2 POISSON_SAMPLES_64[POISSON_SAMPLE_COUNT_64] =
{
	float2( 0.0f, 0.0f ),
	float2( -0.6137453618103923f, -0.7808956971295722f ),
	float2( 0.8396349907359285f, 0.5148990738941996f ),
	float2( 0.47708990757923375f, -0.8641488644567684f ),
	float2( -0.5183893814386409f, 0.8376002240750822f ),
	float2( -0.7166292216763969f, 0.10421895561567021f ),
	float2( 0.9541955550464105f, -0.2278658879141045f ),
	float2( 0.07298871382603131f, 0.7159220702763329f ),
	float2( -0.0347099747936785f, -0.5682566080209154f ),
	float2( 0.4138131836446891f, -0.33668230177375624f ),
	float2( -0.8919507908917611f, -0.3854746481854747f ),
	float2( 0.4801065820308771f, 0.1456783896942405f ),
	float2( -0.42214264360723824f, -0.2240209206214454f ),
	float2( -0.2627986961938346f, 0.36966675979230984f ),
	float2( -0.22711679100439688f, -0.9685543874290692f ),
	float2( 0.49609667541924507f, 0.7447953942204745f ),
	float2( -0.6490114321648822f, 0.4290150720817523f ),
	float2( 0.7775294680193704f, -0.5755429186408113f ),
	float2( 0.0941227107657787f, 0.34521436940035277f ),
	float2( 0.8726827348718671f, 0.14381430578828425f ),
	float2( -0.1338900905065136f, 0.9583632335417395f ),
	float2( 0.16445490902755255f, -0.9745738219466062f ),
	float2( -0.34805189396799663f, -0.5885043414766403f ),
	float2( 0.2648261975675472f, -0.0946661592563603f ),
	float2( 0.47274077325050595f, 0.45132443393840477f ),
	float2( -0.34504049274816334f, 0.0697812845478144f ),
	float2( 0.6404121575783438f, -0.1068484547531138f ),
	float2( 0.22407087125878208f, -0.7088502280656616f ),
	float2( 0.262030798537773f, 0.9629978106646876f ),
	float2( -0.10181371695718827f, -0.2841696684665458f ),
	float2( -0.9742683354152051f, -0.06506226911890828f ),
	float2( -0.7148000672388813f, -0.17676257549106172f ),
	float2( -0.28177298941055434f, 0.6757885038629476f ),
	float2( -0.9594845744962606f, 0.19314774481274302f ),
	float2( -0.6418970515500121f, -0.4528861034045113f ),
	float2( 0.7365329189328603f, -0.32624851940936456f ),
	float2( 0.18666609452749006f, -0.4114609056250106f ),
	float2( -0.10414970224668958f, 0.18996274753275677f ),
	float2( 0.4934882186050703f, -0.5647875461398197f ),
	float2( 0.25072283720535804f, 0.5196222400196572f ),
	float2( -0.877989996696877f, 0.4515488832723437f ),
	float2( -0.22879602308543956f, -0.7563989563542198f ),
	float2( 0.6835811268285786f, 0.28361806744677326f ),
	float2( 0.2145634298400418f, 0.17039060195241867f ),
	float2( -0.44622117602450484f, 0.522521541643356f ),
	float2( -0.03067053418328125f, -0.8273332701031265f ),
	float2( -0.6630333589858441f, 0.6335995288061791f ),
	float2( -0.454020498267266f, 0.29801370886521317f ),
	float2( -0.23738833393554645f, -0.1511433792579605f ),
	float2( -0.7850728219500956f, -0.6056084471598198f ),
	float2( 0.06636222244920026f, 0.9664241013366477f ),
	float2( -0.10617644151564458f, 0.6054836544671671f ),
	float2( 0.9996991718299265f, -0.01206290544284586f ),
	float2( 0.29113392856234227f, 0.7209610549204241f ),
	float2( -0.5321363635827094f, -0.6155820521638421f ),
	float2( 0.6527544016879371f, 0.6097245453678809f ),
	float2( 0.099930281508729f, -0.25063986191309257f ),
	float2( 0.36336091896406947f, 0.30345415413287735f ),
	float2( -0.7889191755898228f, 0.29258491762484135f ),
	float2( -0.23219616384450412f, -0.4305100630680096f ),
	float2( -0.33370941322125347f, 0.8624630262816928f ),
	float2( 0.6103265666908292f, -0.7371579447528488f ),
	float2( -0.55412663967075f, 0.01582440613859224f ),
	float2( 0.9324763565363031f, 0.35134577354643487f ),
};

#endif /* __Q_RENDER_SHADER_POISSON_H__ */
