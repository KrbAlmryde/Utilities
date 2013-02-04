/*============================================================================= 
| 	Assignment: Program #1(a): The Quadratic Formula 
| 		Author: Kyle Almryde
| Sect. Leader: Lane Simons
| 
|		Course: CSc 227 
|	Instructor: L. McCann 
|	  Due Date: January 23, 2012, at 10:00 p.m. 
| 
|  Description: This program requests from the user the coefficients 
| 				a, b, and c of the quadratic equation ax^2 + bx + x = 0 
| 				and displays to the terminal the roots of the equation. 
| 				Note that this program doesn't check for invalid input. 
| 
| Deficiencies: None; this program meets specifications.
*===========================================================================*/

import java.util.*;		// Gives easy access to Jaca API's "util" package

public class Prog1a
{
	static double INCHES_TO_METERS = 0.0254;	//1 in. = 0.0254 meters
	static double POUNDS_TO_KG = 0.4536; 		// 1 lb. = 0.4536 kilograms
	
	public static void main (String [] args)
	{
		double	a,				// coefficient of the x^2 term
				b,				// coefficient of the x^1 term
				c,				// coefficient of the x^0 term
				discriminant,	// equals b^2-4ac
				root1, root2;	// the roots of the quadratic equation
		
		
		Scanner keyboard = new Scanner (System.in);
		
		System.out.println("\nThis program will find the roots of the"
						+ " quadratic equation\nax^2 + bx + c = 0,"
						+ " assuming that a is not zero and that"
						+ " the discriminant\nis not negative.");
		
		System.out.print("\nEnter the value of a in the equation: ");
		a = keyboard.nextDouble();
		
		System.out.print("\nEnter the value of b in the equation: ");
		b = keyboard.nextDouble();
		
		System.out.print("\nEnter the value of c in the equation: ");
		c = keyboard.nextDouble();
			
		
		discriminant = Math.sqrt(b*b - 4*a*c);
		root1 = (-b + discriminant) / (2*a);
		root2 = (-b - discriminant) / (2*a);
		
		System.out.println("\nThe roots of the quadratic equation\n"
						+ "(" + a + ")x^2 + (" + b + ")x + (" + c + ")\n"
						+ "are " + root1 + " and " + root2 + ".\n");

	} // main

}	// class Prog1a