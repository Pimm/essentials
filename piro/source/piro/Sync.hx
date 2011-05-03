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
import piro.Async;

/**
 * A synchronous value. This class extends the Async class, so it can be used in place of an instance of that class.
 * 
 * You can construct instances of this class wherever you want to return a synchronous value, but the Async type is required.
 */
class Sync<Type> extends Async<Type> {
	/**
	 * Creates a new synchronous value.
	 */
	public function new(value:Type):Void {
		super(null);
		this.value = value;
	}
	public override function bind<ReturnType>(listener:Type -> ReturnType):AsyncBond<ReturnType> {
		return new AsyncBond<ReturnType>(new Sync<ReturnType>(listener(value)));
	}
	public override function unbind<ReturnType>(listener:Type -> ReturnType):Void {
	}
	#if production
	public override function yield(value:Type):Void {
	#else
	public override function yield(value:Type, ?positionInformation:haxe.PosInfos):Void {
	#end
	}
}
