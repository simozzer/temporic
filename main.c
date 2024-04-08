//
// This is the standard "HELLO WORLD" sample
//

#include <lib.h>
#include <sys/sound.h>

void setMetricsForFullScreen();
void setMetricsForLeftScreen();
void setMetricsForRightScreen();
void setMetricsForTopScreen();
void setMetricsForBottomScreen();
void wrapScreenLeft();
void wrapScreenRight();
void shredScreenLeft();
void shredScreenRight();
void shredScreenHorizontal();
void wrapScreenUp();
void wrapScreenDown();
void shake();

void main()
{
	char i;
	poke(0x26a,10);
	//for(i=0;i<14;i++) {
		printf("--------------------------------------");
		printf("ABCDEFGHIJKLMNOPQR-+STUVWYXZ0123456789");
		printf("a12345678901234567+-012345678901234567");
		printf("ABCDEFGHIJKLMNOPQR-+STUVWYXZ0123456789");
		printf("b12345678901234567+-012345678901234567");
		printf("ABCDEFGHIJKLMNOPQR-+STUVWYXZ0123456789");
		printf("c12345678901234567+-012345678901234567");
		printf("ABCDEFGHIJKLMNOPQR-+STUVWYXZ0123456789");
		printf("d12345678901234567+-012345678901234567");
		printf("ABCDEFGHIJKLMNOPQR-+STUVWYXZ0123456789");
		printf("e12345678901234567+-012345678901234567");
		printf("ABCDEFGHIJKLMNOPQR-+STUVWYXZ0123456789");
		printf("f12345678901234567+-012345678901234567");
		printf("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");
		printf("012345678901234567+-012345678901234567");
		printf("ABCDEFGHIJKLMNOPQR-+STUVWYXZ0123456789");
		printf("a12345678901234567+-012345678901234567");
		printf("ABCDEFGHIJKLMNOPQR-+STUVWYXZ0123456789");
		printf("b12345678901234567+-012345678901234567");
		printf("ABCDEFGHIJKLMNOPQR-+STUVWYXZ0123456789");
		printf("c12345678901234567+-012345678901234567");
		printf("ABCDEFGHIJKLMNOPQR-+STUVWYXZ0123456789");
		printf("d12345678901234567+-012345678901234567");
		printf("ABCDEFGHIJKLMNOPQR-+STUVWYXZ0123456789");
		printf("e12345678901234567+-012345678901234567");
		printf("ABCDEFGHIJKLMNOPQR-+STUVWYXZ0123456789");
		printf("#####################################");
	//}
	setMetricsForFullScreen();
	doEffects();



	setMetricsForLeftScreen();	
	doEffects();


	setMetricsForRightScreen();
	doEffects();	

	setMetricsForTopScreen();
	doEffects();	
	
	
	setMetricsForBottomScreen();
	doEffects();

}

void doEffects()
{
	wrapScreenLeft();
	wrapScreenRight();
	shredScreenLeft();
	shredScreenRight();
	shredScreenHorizontal();	
	wrapScreenUp();
	
	//wrapScreenDown();
}
