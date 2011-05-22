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
package;
import piro.Async;
import piro.Bond;
import piro.Sync;

//class BindVoid {
//	public static function bind<Datatype>(listener:Void -> Void, signal:Signal<Datatype>):Void {
//		trace("Void");
//	}
//}
//class BindVoidPropagationControl {
//	public static function bind<Datatype>(listener:Void -> Bool, signal:Signal<Datatype>):Void {
//		trace("Void pro-control");
//	}
//}
//class BindRegular {
//	public static function bind<Datatype>(listener:Datatype -> Void, signal:Signal<Datatype>):Void {
//		trace("Regular");
//	}
//}
//class BindRegularPropagationControl {
//	public static function bind<Datatype>(listener:Datatype -> Bool, signal:Signal<Datatype>):Void {
//		trace("Regular pro-control");
//	}
//}
//class BindSubject {
//	public static function bind<Datatype, Subject>(listener:Datatype -> Subject -> Void, signal:Signal<Datatype>):Void {
//		trace("Subject");
//	}
//}
//class BindSubjectPropagationControl {
//	public static function bind<Datatype, Subject>(listener:Datatype -> Subject -> Bool, signal:Signal<Datatype>):Void {
//		trace("Subject pro-control");
//	}
//}
class ResultBond<ReturnType> extends Bond {
	/**
	 * The bonds associated with this one, that will be destroyed when this one is destroyed.
	 */
	private var associatedBonds:Array<Bond>;
	/**
	 * The result returned by the associated listener, represented as an asynchronous value.
	 */
	public var result(default, null):Async<ReturnType>;
	public override function destroy():Void {
		for (associatedBond in associatedBonds) {
			associatedBond.destroy();
		}
	}
}
class Wait1 {
	/**
	 * Notifies this listener as soon as the passed value is filled in. If the passed value has already been filled in, this
	 * listener will be notified immediately, synchronous, without delay. So note that the listener you call this method on might
	 * be notified directly.
	 *
	 * Returns the bond between the passed value and this passed listener. You can use that bond to unbind the passed value and
	 * the this listener by calling the destroy method.
	 *
	 * Listeners will be notified in the order in which they are added.
	 */
	public static inline function wait<Type>(listener:Type -> Void, value:Async<Type>):Bond {
		return value.bind(listener);
	}
}
class WaitForResult1 {
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
	public static function wait<Type, ReturnType>(listener:Type -> ReturnType, value:Async<Type>):ResultBond<ReturnType> {
		var bond:ResultBond<ReturnType> = new ResultBond();
		// Create the result property of the returned bond.
		untyped(bond).result = new Async(WaitForResult1);
		untyped(bond).associatedBonds = [value.bind(function(value:Type):Void {
				bond.result.yield(listener(value));
			})];
		return bond;
	}
}
class Wait2 {
	/**
	 * Notifies this listener as soon as both passed values are filled in. If the passed values are already filled in, this
	 * listener will be notified immediately, synchronous, without delay. So note that the listener you call this method on might
	 * be notified directly.
	 *
	 * Returns the bond between the passed values and this passed listener. You can use that bond to unbind the passed values and
	 * the this listener by calling the destroy method.
	 *
	 * Listeners will be notified in the order in which they are added.
	 */
	public static function wait<FirstType, LastType>(listener:FirstType -> LastType -> Void, firstValue:Async<FirstType>, lastValue:Async<LastType>):Bond {
		// See if both asynchronous values are already yielded. If so, notify the listener directly.
		if (untyped(firstValue).yielded && untyped(lastValue).yielded) {
			listener(untyped(firstValue).value, untyped(lastValue).value);
			return new Bond();
		} else {
			// We're using the result bond here, because of it's destroy implementation.
			var bond:ResultBond<Void> = new ResultBond();
			untyped(bond).associatedBonds = [firstValue.bind(function(value:FirstType):Void {
					untyped(lastValue).yielded && listener(value, untyped(lastValue).value);
				}), lastValue.bind(function(value:LastType):Void {
					untyped(firstValue).yielded && listener(untyped(firstValue).value, value);
				})];
			return bond;
		}
	}
}
class WaitForResult2 {
	/**
	 * Notifies this listener as soon as both passed values are filled in. If the passed values are already filled in, this
	 * listener will be notified immediately, synchronous, without delay. So note that the listener you call this method on might
	 * be notified directly.
	 *
	 * Returns the bond between the passed values and this passed listener. This bond has a result property, which represents the
	 * value returned by this listener. You can use that property if the value returned by this listener is of interest to you.
	 * Additionally, you can use that bond to unbind the passed values and the this listener by calling the destroy method.
	 *
	 * Listeners will be notified in the order in which they are added.
	 */
	public static function wait<FirstType, LastType, ReturnType>(listener:FirstType -> LastType -> ReturnType, firstValue:Async<FirstType>, lastValue:Async<LastType>):ResultBond<ReturnType> {
		// See if both asynchronous values are already yielded. If so, notify the listener directly.
		if (untyped(firstValue).yielded && untyped(lastValue).yielded) {
			var bond:ResultBond<ReturnType> = new ResultBond();
			untyped(bond).result = new Sync(listener(untyped(firstValue).value, untyped(lastValue).value));
			untyped(bond).associatedBonds = [];
			return bond;
		} else {
			var bond:ResultBond<ReturnType> = new ResultBond();
			untyped(bond).result = new Async(WaitForResult2);
			untyped(bond).associatedBonds = [firstValue.bind(function(value:FirstType):Void {
					untyped(lastValue).yielded && bond.result.yield(listener(value, untyped(lastValue).value));
				}), lastValue.bind(function(value:LastType):Void {
					untyped(firstValue).yielded && bond.result.yield(listener(untyped(firstValue).value, value));
				})];
			return bond;
		}
	}
}
class Wait3 {
	/**
	 * Notifies this listener as soon as all passed values are filled in. If the passed values are already filled in, this
	 * listener will be notified immediately, synchronous, without delay. So note that the listener you call this method on might
	 * be notified directly.
	 *
	 * Returns the bond between the passed values and this passed listener. You can use that bond to unbind the passed values and
	 * the this listener by calling the destroy method.
	 *
	 * Listeners will be notified in the order in which they are added.
	 */
	public static function wait<FirstType, SecondType, LastType>(listener:FirstType -> SecondType -> LastType -> Void, firstValue:Async<FirstType>, secondValue:Async<SecondType>, lastValue:Async<LastType>):Bond {
		// See if all asynchronous values are already yielded. If so, notify the listener directly.
		if (untyped(firstValue).yielded && untyped(secondValue).yielded && untyped(lastValue).yielded) {
			listener(untyped(firstValue).value, untyped(secondValue).value, untyped(lastValue).value);
			return new Bond();
		} else {
			// We're using the result bond here, because of it's destroy implementation.
			var bond:ResultBond<Void> = new ResultBond();
			var notifyListenerIfYielded = function(?value:Dynamic):Void {
				untyped(firstValue).yielded && untyped(secondValue).yielded && untyped(lastValue).yielded && listener(untyped(firstValue).value, untyped(secondValue).value, untyped(lastValue).value);
			}
			untyped(bond).associatedBonds = [firstValue.bind(notifyListenerIfYielded), secondValue.bind(notifyListenerIfYielded), lastValue.bind(notifyListenerIfYielded)];
			return bond;
		}
	}
}
class WaitForResultAsync3 {
	/**
	 * Notifies this listener as soon as all passed values are filled in. If the passed values are already filled in, this
	 * listener will be notified immediately, synchronous, without delay. So note that the listener you call this method on might
	 * be notified directly.
	 *
	 * Returns the bond between the passed values and this passed listener. This bond has a result property, which represents the
	 * value returned by this listener. You can use that property if the value returned by this listener is of interest to you.
	 * Additionally, you can use that bond to unbind the passed values and the this listener by calling the destroy method.
	 *
	 * Listeners will be notified in the order in which they are added.
	 */
	public static function wait<FirstType, SecondType, LastType, ReturnType>(listener:FirstType -> SecondType -> LastType -> Async<ReturnType>, firstValue:Async<FirstType>, secondValue:Async<SecondType>, lastValue:Async<LastType>):ResultBond<ReturnType> {
		// See if all asynchronous values are already yielded. If so, notify the listener directly.
		if (untyped(firstValue).yielded && untyped(secondValue).yielded && untyped(lastValue).yielded) {
			var bond:ResultBond<ReturnType> = new ResultBond();
			untyped(bond).result = listener(untyped(firstValue).value, untyped(secondValue).value, untyped(lastValue).value);
			untyped(bond).associatedBonds = [];
			return bond;
		} else {
			var bond:ResultBond<ReturnType> = new ResultBond();
			untyped(bond).result = new Async(WaitForResultAsync3);
			var notifyListenerIfYielded = function(?value:Dynamic):Void {
				untyped(firstValue).yielded && untyped(secondValue).yielded && untyped(lastValue).yielded && listener(untyped(firstValue).value, untyped(secondValue).value, untyped(lastValue).value).bind(function(value:ReturnType):Void {
					bond.result.yield(value);
				});
			}
			untyped(bond).associatedBonds = [firstValue.bind(notifyListenerIfYielded), secondValue.bind(notifyListenerIfYielded), lastValue.bind(notifyListenerIfYielded)];
			return bond;
		}
	}
}
class WaitForResult3 {
	/**
	 * Notifies this listener as soon as all passed values are filled in. If the passed values are already filled in, this
	 * listener will be notified immediately, synchronous, without delay. So note that the listener you call this method on might
	 * be notified directly.
	 *
	 * Returns the bond between the passed values and this passed listener. This bond has a result property, which represents the
	 * value returned by this listener. You can use that property if the value returned by this listener is of interest to you.
	 * Additionally, you can use that bond to unbind the passed values and the this listener by calling the destroy method.
	 *
	 * Listeners will be notified in the order in which they are added.
	 */
	public static function wait<FirstType, SecondType, LastType, ReturnType>(listener:FirstType -> SecondType -> LastType -> ReturnType, firstValue:Async<FirstType>, secondValue:Async<SecondType>, lastValue:Async<LastType>):ResultBond<ReturnType> {
		// See if all asynchronous values are already yielded. If so, notify the listener directly.
		if (untyped(firstValue).yielded && untyped(secondValue).yielded && untyped(lastValue).yielded) {
			var bond:ResultBond<ReturnType> = new ResultBond();
			untyped(bond).result = new Sync(listener(untyped(firstValue).value, untyped(secondValue).value, untyped(lastValue).value));
			untyped(bond).associatedBonds = [];
			return bond;
		} else {
			var bond:ResultBond<ReturnType> = new ResultBond();
			untyped(bond).result = new Async(WaitForResult3);
			var notifyListenerIfYielded = function(?value:Dynamic):Void {
				untyped(firstValue).yielded && untyped(secondValue).yielded && untyped(lastValue).yielded && bond.result.yield(listener(untyped(firstValue).value, untyped(secondValue).value, untyped(lastValue).value));
			}
			untyped(bond).associatedBonds = [firstValue.bind(notifyListenerIfYielded), secondValue.bind(notifyListenerIfYielded), lastValue.bind(notifyListenerIfYielded)];
			return bond;
		}
	}
}
//class Wait4 {
//	/**
//	 * Notifies this listener as soon as all passed values are filled in. If the passed values are already filled in, this
//	 * listener will be notified immediately, synchronous, without delay. So note that the listener you call this method on might
//	 * be notified directly.
//	 *
//	 * Returns the bond between the passed values and this passed listener. This bond has a result property, which represents the
//	 * value returned by this listener. You can use that property if the value returned by this listener is of interest to you.
//	 * Additionally, you can use that bond to unbind the passed values and the this listener by calling the destroy method.
//	 *
//	 * Listeners will be notified in the order in which they are added.
//	 */
//	public static function wait<FirstType, SecondType, ThirdType, LastType, ReturnType>(listener:FirstType -> SecondType -> ThirdType -> LastType -> ReturnType, firstValue:Async<FirstType>, secondValue:Async<SecondType>, thirdValue:Async<ThirdType>, lastValue:Async<LastType>):AsyncBond<ReturnType> {
//		// See if all asynchronous values are already yielded. If so, notify the listener directly.
//		if (untyped(firstValue).yielded && untyped(secondValue).yielded && untyped(thirdValue).yielded && untyped(lastValue).yielded) {
//			return new AsyncBond(new Sync(listener(untyped(firstValue).value, untyped(secondValue).value, untyped(thirdValue).value, untyped(lastValue).value)));
//		} else {
//			var bond:AsyncBond<ReturnType> = new AsyncBond(new Async(Wait3));
//			var notifyListenerIfYielded = function(?value:Dynamic):Void {
//				untyped(firstValue).yielded && untyped(secondValue).yielded && untyped(thirdValue).yielded && untyped(lastValue).yielded && bond.result.yield(listener(untyped(firstValue).value, untyped(secondValue).value, untyped(thirdValue).value, untyped(lastValue).value));
//			}
//			firstValue.bind(notifyListenerIfYielded);
//			secondValue.bind(notifyListenerIfYielded);
//			thirdValue.bind(notifyListenerIfYielded);
//			lastValue.bind(notifyListenerIfYielded);
//			return bond;
//		}
//	}
//}
