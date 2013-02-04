1/18/2012

//Variables in JAVA

<type> <identifier> ;
int i, j, k;

//instead of putting all on one line as above do..


int i, // comment for why you have this variable
	j, // _______________
	k; // _____________
	
/*when you write code put documentation in there. For that matter, document AS YOU CODE. If you write a
block of code, document why you did it, etc. it will make your life a lot easier later on, just do it */


<type> <identifier>
int		i=10, j;
j=9


<type> <identifier>
int		a,b=4;

//whats happening here? 
//We are stating that a is undefined, b is equal to 4


//Assignment Statement
	<identifier> = <expression>;
			i=j
// the = sign is actually an operator, which will return a value, so you can do fun things like 

		a=b=c=14
		
	//what this does is assign the value 14 to each letter, FROM THE RIGHT TO LEFT!!! 
	//This is known as Right to Left Associativity, meaning JAVA executes from right to left
	
//Constants


	int DAYS_IN_WEEK = 7 	//this is declaring a variable
							//basic rules of identifiers, its gotta start with a letter, cant have spaces.
	
//To make that into a constant

	final int DAYS_IN_WEEK = 7
	//why do we want to assign a constant? 

//In your code, you want to use meaningful identifier names. Something like DAYS_IN_WEEK is a good one,
//something like a or b, not so much. It needs to be very easy to understand, so when someone reads
//your code later, they have no question about why your used that name.
//The whole point is to make sure your code clear and understandable

//MATH Operators

+ - * / %
	
		//how would you long divide 3 into 7? (2, remainder 1)
	
	a = 7 / 3;		// a=2. Because 7 and 3 are both ints (integers), so the result is an integer
	b = 7 % 3		// b=1 Because its a mod type...
	
//TYPES
	integer types			floating-point type
		long 					double	//this is the default FPU
		int						float
		short					
		byte					

//Arithmetic Promotion
	double * byte	//what happens if we have this situation, what will happen?
	double * byte	=> double * double //JAVA will promote the byte into a double and finish the operation
	
	int * float //what will happen with this situation?
	int * float  =>. float * float
	
	byte * byte //what about here?
	byte * byte	 => int * int
	
	long * float => float * float
	int + float => float + float
	
	//if you wanted to keep JAVA from promoting the data type, 

//Assignment Conversions & Type Casting

	byte bar = 3.5; //this wont work because the byte is an integer type and cant store the .5
	
	byte bar = (byte) 3.5; //this will keep the data type as a byte, but it will still loose the .5, 
						   //this is not an implicit opperation
						   
	int 	total, count;
	double   average;
	
	average = total / count
	average = (double)  total/count
		   (3)	(1)			(2)