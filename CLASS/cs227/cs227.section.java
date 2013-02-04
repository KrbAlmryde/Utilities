
1/18/2012

/*
 Operator Precedence is Top-Down
 http://bmanolov.free.fr/javaoperators.php 
 this is a good site to summarize
*/

//remember
int + float => float + float //because floats are more accurate than an int(eger)

int testing = (int) 3.0
float mystery = 3 * 5 / ((int) 2.0 + 1);
						// cast to 2
						// parenths for 3
/*which leaves us with */	3 * 5 / (3)
				
double result2 = (double) 3 / 5;	//alternatly you can do the following
double result2 = 3 * 1.0 / 5


/*
Everything in Java is case sensitive

	Always capitalize your class names
	variable names can take advantage of camelCasing 
	
	characters are denoted as a single character in '' ie 'a'
	char 'a'

*/

//Using escape sequences, using a backslash(\) initiates it //
System.out.println("asdljadafjhasdkjfhadifljhad \" sadf\n asdf ")



// the modulus (%) takes the remainder //

// how do we go from 123, to x=3, y=2, z=1 //
		123 % 10 = 3
		123 / 10 = 12
		12 % 10 = 1
		12 / 10 = 1
		1 % 10 = 1