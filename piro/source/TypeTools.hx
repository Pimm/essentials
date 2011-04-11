/**
 * Copyright (c) 2009-2011, the essentials team.
 *
 * This file is part of Piro. Piro is the essential haXe library for event-driven programming.
 *
 * Piro is free software: you may redistribute and/or modify this file providing that the following condition is met:
 *	* Redistributions of this software in source form must retain or reproduce the above copyright notice, this condition and
 *	  the following disclaimer.
 *
 * THIS SOFTWARE IS PROVIDED BY THE HSL CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * ESSENTIALS TEAM BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Alternatively, this file may be used under the terms of either the X11/MIT License, the Simplified BSD License,
 * the GNU Lesser General Public License Version 2.1 or later or the GNU General Public License Version 2 or later, in which
 * case the provisions of that license are applicable instead of those above.
 */
package;

/**
 * More advanced operations for reflection, in addition to the ones that are defined in the Type class and the Reflect class.
 */
class TypeTools {
	/**
	 * Returns a list of all the complete names of all the classes the passed value is an instance of. If the passed value itself
	 * is a class, this method will return a list containing its complete name and all its super classes. For example, if you
	 * pass an instance of the Sprite class, or the Sprite class itself, this method will return a list containing
	 * "flash.display.Sprite", "flash.display.DisplayObjectContainer", "flash.display.InteractiveObject",
	 * "flash.display.DisplayObject" and "flash.events.EventDispatcher".
	 * 
	 * If the passed value is null or an enum, an empty list will be returned. The behaviour when passing integers or boolean
	 * values, or even the Int class or the Bool class itself, is unpredictable. This method never returns null.
	 */
	public static function getClassNames(value:Dynamic):List<String> {
		var result:List<String> = new List();
		// Perform a null-enum check when compiling to JavaScript, as other lines in this method except the value to be non-null and
		// non-enum.
		#if js
		if (null == value || null != value.__enum__ || null != value.__ename__) {
			return result;
		}
		#end
		// Retrieve the most derived class of the passed value. If the passed value is a class, use the value itself as class. If the
		// passed value is an instance of a class, use the class the value is an instance of.
		var valueClass:Class<Dynamic> =
			#if js
			untyped if (null == value.__class__) {
				value;
			} else {
				value.__class__;
			}
			#else
			untyped if (Std.is(value, Class)) {
				value;
			} else {
				Type.getClass(value);
			}
			#end
		// Store the names of all the classes of the value, including super classes.
		while (null != valueClass) {
			#if js
			result.add(untyped(valueClass).__name__.join("."));
			valueClass = untyped(valueClass).__super__;
			#else
			result.add(Type.getClassName(valueClass));
			valueClass = Type.getSuperClass(valueClass);
			#end
		}
		return result;
	}
	/**
	 * Returns the short name of all the most derived class of the passed value is an instance of. If the passed value itself
	 * is a class, this method will its short name. For example, if you pass an instance of the Sprite class, or the Sprite class
	 * itself, this method will return "Sprite".
	 * 
	 * If the passed value is null, "null" will be returned. The behaviour when passing enums, integers or boolean values, or
	 * even the Int class or the Bool class itself, is unpredictable. This method never returns null.
	 */
	public static function getShortClassName(value:Dynamic):String {
		// TODO: Handle enums gracefully.
		if (null == value) {
			return "null";
		}
		// Retrieve the most derived class of the passed value. If the passed value is a class, use the value itself as class. If the
		// passed value is an instance of a class, use the class the value is an instance of.
		var valueClass:Class<Dynamic> =
			#if js
			untyped if (null == value.__class__) {
				value;
			} else {
				value.__class__;
			}
			#else
			untyped if (Std.is(value, Class)) {
				value;
			} else {
				Type.getClass(value);
			}
			#end
		#if js
		return untyped(valueClass).__name__[-1 + untyped(valueClass).__name__.length];
		#else
		// TODO: Implement this method for other targets than JS.
		return null;
		#end
	}
}
