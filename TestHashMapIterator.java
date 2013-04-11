/**
 * Just a simple class to test iterating through a HashMap
 *
 *
 *
 * @author Kyle Almryde
 *
 */

import java.util.*;        // Gives easy access to Java API's "util" package


public class TestHashMapIterator  {

    private static HashMap<String, Integer> inventory = new HashMap<String, Integer>();

    public TestHashMapIterator() {
        inventory.put("sword", 0);
        inventory.put("wand", 1);
        inventory.put("axe", 2);
        inventory.put("potion", 3);
        inventory.put("gold", 4);
        inventory.put("boobies", 5);
    }

    public static void main(String[] args) {
        TestHashMapIterator map = new TestHashMapIterator();

        for (String key : inventory.keySet()) {
            System.out.println("This is our " + key + "\nThis is our item # " + inventory.get(key));
        }
    }

} // End of TestHashMapIterator