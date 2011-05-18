/**
 * Copyright (c) 2009-2011, the essentials team.
 *
 * This file is part of Piro. Piro is the essential haXe library for event-driven programming.
 *
 * Piro is free software: you may redistribute and/or modify this file providing that the following condition is met:
 *	* Redistributions of this software in source form must retain or reproduce the above copyright notice, this condition and
 *	  the following disclaimer.
 *
 * THIS SOFTWARE IS PROVIDED BY THE ESSENTIALS TEAM "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
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
package piro;
import piro.Bond;

/**
 * An asynchronous value. A value that will be filled in at some point in the future, such as a document that is being
 * downloaded from the Internet; or the contents of a form the user might still be filling in.
 * 
 * You can construct instances of this class wherever you want to return asynchronous values.
 */
class Async<Type> {
	/**
	 * A fake bond before the first real bond and after the last real one.
	 */
	private var sentinel:LinkedAsyncBond<Type, Void>;
	/**
	 * The value of this asynchronous value wrapper.
	 */
	private var value:Type;
	/**
	 * Whether this value has been yielded yet (true) or not (false).
	 */
	private var yielded:Bool;
	#if !production
	/**
	 * The class names of the yielder passed in the constructor.
	 */
	private var yielderClassNames:List<String>;
	#end
	/**
	 * Creates a new asynchronous value.
	 * 
	 * Only the passed yielder is allowed to call the yield method.
	 */
	public function new(yielder:Yielder):Void {
		#if !production
		// Save the class names of the yielder.
		yielderClassNames = TypeTools.getClassNames(yielder);
		#end
	}
	/**
	 * Notifies the passed listener as soon as this value is filled in. If this value has already been filled in, the passed
	 * listener will be notified immediately, synchronous, without delay. So note that the listener you pass might be notified
	 * directly.
	 * 
	 * Returns the bond between this value and the passed listener. This bond has a result property, which represents the value
	 * returned by the passed listener. You can use that property if the value returned by the passed listener is of interest to
	 * you. Additionally, you can use that bond to unbind this value and the passed listener by calling the destroy method.
	 * 
	 * Listeners will be notified in the order in which they are added.
	 */
	public function bind<ReturnType>(listener:Type -> ReturnType):AsyncBond<ReturnType> {
		#if !production
		// If the passed listener is null, throw an exception. Having null for a listener will produce errors when the value is
		// yielded.
		if (null == listener) {
			throw "Argument listener must be non-null";
		}
		#end
		// If this value is already yielded, notify the listener immediately.
		if (yielded) {
			return new AsyncBond<ReturnType>(new Sync<ReturnType>(listener(value)));
		// If this value has not yet been yielded create a bond that contains the listener, so the listener can be notified as soon
		// as this value is yielded.
		} else {
			var bond:LinkedAsyncBond<Type, ReturnType> = new LinkedAsyncBond<Type, ReturnType>(new Async<ReturnType>(this));
			bond.listener = listener;
			// Link the newly created bond.
			if (null == sentinel) {
				bond.next = bond.previous = sentinel =
					// In case of JavaScript, use this shortcut which skips the constructor (for speed reasons).
					#if js
					untyped __new__(LinkedAsyncBond, __js__("$_"));
					#else
					new LinkedAsyncBond<Type, Void>(null);
					#end
				sentinel.next = sentinel.previous = bond;
			} else {
				bond.next = sentinel;
				bond.previous = sentinel.previous;
				sentinel.previous = sentinel.previous.next = bond;
			}
			return bond;
		}
	}
	/**
	 * Cancels the notification of the passed listener when this value is filled in. This method reverses the effect of the
	 * bind method.
	 * 
	 * If the passed listener is not registered to be notified, calling this method has no effect. If the passed listener is
	 * registered to be notified more than once, only one registration will be removed.
	 */
	public function unbind<ReturnType>(listener:Type -> ReturnType):Void {
		// Find the matching bond.
		if (null != sentinel) {
			var bond:LinkedAsyncBond<Type, Dynamic> = sentinel.next;
			while (null != bond.listener) {
				// If the matching bond is found, unlink it.
				if (Reflect.compareMethods(bond.listener, listener)) {
					bond.unlink();
					return;
				}
				bond = bond.next;
			}
		}
	}
	#if debug
	private function toString():String {
		return "[Async]";
	}
	#end
	#if !production
	/**
	 * Checks whether the class name inside the passed position information equals the class name of the yielder as passed in the
	 * constructor. Used in the yield method, as that method may only be called by the yielder.
	 * 
	 * Two notes.
	 * One, by using this method you check whether the caller is of the same type as the yielder, which does not necessarily mean
	 * it's the same instance. This is the expected behavior, as it is consistent with private members.
	 * Two, one could hack his or her way around this check. How to do this should be obvious. The check is not designed to be
	 * unhackable; rather it is designed to prevent developers from accidentally misapplying this class. Nicolas Cannasse once
	 * said "everything should be made accessible, if you know what you're doing".
	 */
	private function verifyCaller(positionInformation:haxe.PosInfos):Void {
		for (yielderClassName in yielderClassNames) {
			if (yielderClassName == positionInformation.className) {
				return;
			}
		}
		throw "This method may only be called by the yielder.";
	}
	#end
	/**
	 * Fills in the value. This method may only be called by the yielder.
	 * 
	 * If this method has been called before, calling this method has no effect.
	 * 
	 * If there are listeners registered to be notified when this value is filled in, they will be notified.
	 */
	#if production
	public function yield(value:Type):Void {
	#else
	public function yield(value:Type, ?positionInformation:haxe.PosInfos):Void {
		// Verify that the caller of this method is the yielder.
		verifyCaller(positionInformation);
	#end
		// If this value has already been yielded, return directly.
		if (yielded) {
			return;
		}
		// Save the value and set the yielded flag, for future calls to the notify method.
		this.value = value;
		yielded = true;
		// Notify the listeners through the bonds.
		if (null != sentinel) {
			var bond:LinkedAsyncBond<Type, Dynamic> = sentinel.next;
			while (null != bond.listener) {
				bond.result.yield(bond.listener(value));
				bond = bond.next;
			}
			// Remove the references to the bonds. They are no longer needed.
			sentinel = null;
		}
	}
}
/**
 * An object that yields an asynchronous value.
 */
typedef Yielder = {}
/**
 * The type of bonds returned by asynchronous values.
 */
class AsyncBond<ReturnType> extends Bond {
	/**
	 * The result returned by the associated listener, represented as an asynchronous value.
	 */
	public var result(default, null):Async<ReturnType>;
	/**
	 * Creates a new bond.
	 */
	public function new(result:Async<ReturnType>):Void {
		super();
		this.result = result;
	}
}
/**
 * A linked bond used internally by asynchronous values.
 */
class LinkedAsyncBond<Type, ReturnType> extends AsyncBond<ReturnType> {
	/**
	 * Whether this bond has been destroyed (false) or not (true).
	 */
	private var inUse:Bool;
	/**
	 * The actual listener, or null if this bond is the sentinel.
	 */
	public var listener:Type -> ReturnType;
	/**
	 * A reference to the next bond.
	 */
	public var next:LinkedAsyncBond<Type, Dynamic>;
	/**
	 * A reference to the previous bond.
	 */
	public var previous:LinkedAsyncBond<Type, Dynamic>;
	/**
	 * Creates a new linked bond.
	 */
	public function new(result:Async<ReturnType>):Void {
		super(result);
		inUse = true;
	}
	public override function destroy():Void {
		// The actual logic for this implementation of the destroy method is in the unlink method. This way, the sentinel can call
		// unlink directly, which is inlined.
		unlink();
	}
	public inline function unlink():Void {
		// If this bond has already been destroyed, don't destroy it again.
		if (inUse) {
			previous.next = next;
			next.previous = previous;
			inUse = false;
			// Clean up the mess, help the garbage collector.
			listener = null;
		}
	}
}
class Wait1 {
	/**
	 * Cancels the notification of the passed listener when this value is filled in. This method reverses the effect of the
	 * bind method.
	 * 
	 * If the passed listener is not registered to be notified, calling this method has no effect. If the passed listener is
	 * registered to be notified more than once, only one registration will be removed.
	 */
	public static inline function cancel<Type>(listener:Type -> Dynamic, value:Async<Type>):Void {
		value.unbind(listener);
	}
	/**
	 * Notifies this listener as soon as the passed value is filled in. If the passed value has already been filled in, this
	 * listener will be notified immediately, synchronous, without delay. So note that the listener you call this method on might
	 * be notified directly.
	 * 
	 * Returns the bond between the passed value and this passed listener. This bond has a result property, which represents the
	 * value returned by this listener. You can use that property if the value returned by this listener is of interest to you.
	 * Additionally, you can use that bond to unbind the passed value and the this listener by calling the destroy method.
	 * 
	 * Listeners will be notified in the order in which they are added.
	 */
	public static inline function wait<Type, ReturnType>(listener:Type -> ReturnType, value:Async<Type>):AsyncBond<ReturnType> {
		return value.bind(listener);
	}
}
///**
// * A linked bond used by the Wait2 class.
// */
//class Wait2Bond<FirstType, SecondType, ReturnType> extends Bond {
//	/**
//	 * The bond between the callListenerIfYielded method of this bond and the first asynchronous value.
//	 */
//	private var firstBond:Bond;
//	/**
//	 * The first asynchronous value.
//	 */
//	private var firstValue:{var value:FirstType; var yielded:Bool;};
//	/**
//	 * The actual listener, or null if this bond is the sentinel.
//	 */
//	public var listener:FirstType -> SecondType -> ReturnType;
//	/**
//	 * The result of the listener as an asynchronous value.
//	 */
//	public var result:Async<ReturnType>;
//	/**
//	 * The bond between the callListenerIfYielded method of this bond and the second asynchronous value.
//	 */
//	private var secondBond:Bond;
//	/**
//	 * The second asynchronous value.
//	 */
//	private var secondValue:{var value:SecondType; var yielded:Bool;};
//	/**
//	 * Creates a new Wait2 bond.
//	 */
//	public function new(listener:FirstType -> SecondType -> ReturnType, firstValue:Async<FirstType>, secondValue:Async<SecondType>):Void {
//		super();
//		result = new Async(this);
//		this.listener = listener;
//		this.firstValue = untyped firstValue;
//		this.secondValue = untyped secondValue;
//		// Call the callListenerIfYielded method directly, just in case both asynchronous values are aleady yielded.
//		if (notifyListenerIfYielded()) {
//			firstBond = new BondHolder();
//			firstValue.bind(notifyListenerIfYielded, firstBond);
//			secondBond = new BondHolder();
//			secondValue.bind(notifyListenerIfYielded, secondBond);
//		}
//	}
//	/**
//	 * Notifies the listener if both values are yielded. Returns false if the listener has been notified.
//	 */
//	private function notifyListenerIfYielded(?bogus:Dynamic):Bool {
//		if (firstValue.yielded && secondValue.yielded) {
//			result.yield(listener(firstValue.value, secondValue.value));
//			// Clean up the mess, help the garbage collector.
//			firstValue = null;
//			secondValue = null;
//			listener = null;
//			return false;
//		} else {
//			return true;
//		}
//	}
//	public override function destroy():Void {
//		if (null != firstBond) {
//			firstBond.destroy();
//			secondBond.destroy();
//			// Clean up the mess, help the garbage collector.
//			firstValue = null;
//			secondValue = null;
//			listener = null;
//		}
//	}
//}
//class Wait2 {
//	public static function wait<FirstType, SecondType, ReturnType>(listener:FirstType -> SecondType -> ReturnType, firstValue:Async<FirstType>, secondValue:Async<SecondType>, ?bondHolder:Bond):Async<ReturnType> {
//		var bond:Wait2Bond<FirstType, SecondType, ReturnType> = new Wait2Bond(listener, firstValue, secondValue);
//		// If a bond holder was passed, inject the bond into it.
//		if (null != bondHolder) {
//			#if !production
//			try {
//				cast(bondHolder, BondHolder);
//			} catch (exception:Dynamic) {
//				throw "Argument bondHolder should be of the type BondHolder instead of the type " + TypeTools.getShortClassName(bondHolder);
//			}
//			#end
//			untyped(bondHolder).innerBond = bond;
//		}
//		return bond.result;
//	}
//}
///**
// * A linked bond used by the Wait3 class.
// */
//class Wait3Bond<FirstType, SecondType, ThirdType, ReturnType> extends Bond {
//	/**
//	 * The bond between the callListenerIfYielded method of this bond and the first asynchronous value.
//	 */
//	private var firstBond:Bond;
//	/**
//	 * The first asynchronous value.
//	 */
//	private var firstValue:{var value:FirstType; var yielded:Bool;};
//	/**
//	 * The actual listener, or null if this bond is the sentinel.
//	 */
//	public var listener:FirstType -> SecondType -> ThirdType -> ReturnType;
//	/**
//	 * The result of the listener as an asynchronous value.
//	 */
//	public var result:Async<ReturnType>;
//	/**
//	 * The bond between the callListenerIfYielded method of this bond and the second asynchronous value.
//	 */
//	private var secondBond:Bond;
//	/**
//	 * The second asynchronous value.
//	 */
//	private var secondValue:{var value:SecondType; var yielded:Bool;};
//	/**
//	 * The bond between the callListenerIfYielded method of this bond and the third asynchronous value.
//	 */
//	private var thirdBond:Bond;
//	/**
//	 * The third asynchronous value.
//	 */
//	private var thirdValue:{var value:ThirdType; var yielded:Bool;};
//	/**
//	 * Creates a new Wait3 bond.
//	 */
//	public function new(listener:FirstType -> SecondType -> ThirdType -> ReturnType, firstValue:Async<FirstType>, secondValue:Async<SecondType>, thirdValue:Async<ThirdType>):Void {
//		super();
//		result = new Async(this);
//		this.listener = listener;
//		this.firstValue = untyped firstValue;
//		this.secondValue = untyped secondValue;
//		this.thirdValue = untyped thirdValue;
//		// Call the callListenerIfYielded method directly, just in case all three asynchronous values are aleady yielded.
//		if (notifyListenerIfYielded()) {
//			firstBond = new BondHolder();
//			firstValue.bind(notifyListenerIfYielded, firstBond);
//			secondBond = new BondHolder();
//			secondValue.bind(notifyListenerIfYielded, secondBond);
//			thirdBond = new BondHolder();
//			thirdValue.bind(notifyListenerIfYielded, thirdValue);
//		}
//	}
//	/**
//	 * Notifies the listener if all three values are yielded. Returns false if the listener has been notified.
//	 */
//	private function notifyListenerIfYielded(?bogus:Dynamic):Bool {
//		if (firstValue.yielded && secondValue.yielded && thirdValue.yielded) {
//			result.yield(listener(firstValue.value, secondValue.value, thirdValue.value));
//			// Clean up the mess, help the garbage collector.
//			firstValue = null;
//			secondValue = null;
//			thirdValue = null;
//			listener = null;
//			return false;
//		} else {
//			return true;
//		}
//	}
//	public override function destroy():Void {
//		if (null != firstBond) {
//			firstBond.destroy();
//			secondBond.destroy();
//			thirdBond.destroy();
//			// Clean up the mess, help the garbage collector.
//			firstValue = null;
//			secondValue = null;
//			thirdValue = null;
//			listener = null;
//		}
//	}
//}
