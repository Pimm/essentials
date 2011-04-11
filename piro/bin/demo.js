$estr = function() { return js.Boot.__string_rec(this,''); }
if(typeof js=='undefined') js = {}
js.Boot = function() { }
js.Boot.__name__ = ["js","Boot"];
js.Boot.__unhtml = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
js.Boot.__trace = function(v,i) {
	var msg = i != null?i.fileName + ":" + i.lineNumber + ": ":"";
	msg += js.Boot.__unhtml(js.Boot.__string_rec(v,"")) + "<br/>";
	var d = document.getElementById("haxe:trace");
	if(d == null) alert("No haxe:trace element defined\n" + msg); else d.innerHTML += msg;
}
js.Boot.__clear_trace = function() {
	var d = document.getElementById("haxe:trace");
	if(d != null) d.innerHTML = ""; else null;
}
js.Boot.__closure = function(o,f) {
	var m = o[f];
	if(m == null) return null;
	var f1 = function() {
		return m.apply(o,arguments);
	};
	f1.scope = o;
	f1.method = m;
	return f1;
}
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ != null || o.__ename__ != null)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__ != null) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2, _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				return str + ")";
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			var _g = 0;
			while(_g < l) {
				var i1 = _g++;
				str += (i1 > 0?",":"") + js.Boot.__string_rec(o[i1],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) { ;
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
}
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0, _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
}
js.Boot.__instanceof = function(o,cl) {
	try {
		if(o instanceof cl) {
			if(cl == Array) return o.__enum__ == null;
			return true;
		}
		if(js.Boot.__interfLoop(o.__class__,cl)) return true;
	} catch( e ) {
		if(cl == null) return false;
	}
	switch(cl) {
	case Int:
		return Math.ceil(o%2147483648.0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return o === true || o === false;
	case String:
		return typeof(o) == "string";
	case Dynamic:
		return true;
	default:
		if(o == null) return false;
		return o.__enum__ == cl || cl == Class && o.__name__ != null || cl == Enum && o.__ename__ != null;
	}
}
js.Boot.__init = function() {
	js.Lib.isIE = typeof document!='undefined' && document.all != null && typeof window!='undefined' && window.opera == null;
	js.Lib.isOpera = typeof window!='undefined' && window.opera != null;
	Array.prototype.copy = Array.prototype.slice;
	Array.prototype.insert = function(i,x) {
		this.splice(i,0,x);
	};
	Array.prototype.remove = Array.prototype.indexOf?function(obj) {
		var idx = this.indexOf(obj);
		if(idx == -1) return false;
		this.splice(idx,1);
		return true;
	}:function(obj) {
		var i = 0;
		var l = this.length;
		while(i < l) {
			if(this[i] == obj) {
				this.splice(i,1);
				return true;
			}
			i++;
		}
		return false;
	};
	Array.prototype.iterator = function() {
		return { cur : 0, arr : this, hasNext : function() {
			return this.cur < this.arr.length;
		}, next : function() {
			return this.arr[this.cur++];
		}};
	};
	if(String.prototype.cca == null) String.prototype.cca = String.prototype.charCodeAt;
	String.prototype.charCodeAt = function(i) {
		var x = this.cca(i);
		if(x != x) return null;
		return x;
	};
	var oldsub = String.prototype.substr;
	String.prototype.substr = function(pos,len) {
		if(pos != null && pos != 0 && len != null && len < 0) return "";
		if(len == null) len = this.length;
		if(pos < 0) {
			pos = this.length + pos;
			if(pos < 0) pos = 0;
		} else if(len < 0) len = this.length + len - pos;
		return oldsub.apply(this,[pos,len]);
	};
	$closure = js.Boot.__closure;
}
js.Boot.prototype.__class__ = js.Boot;
js.Lib = function() { }
js.Lib.__name__ = ["js","Lib"];
js.Lib.isIE = null;
js.Lib.isOpera = null;
js.Lib.document = null;
js.Lib.window = null;
js.Lib.alert = function(v) {
	alert(js.Boot.__string_rec(v,""));
}
js.Lib.eval = function(code) {
	return eval(code);
}
js.Lib.setErrorHandler = function(f) {
	js.Lib.onerror = f;
}
js.Lib.prototype.__class__ = js.Lib;
if(typeof jjd=='undefined') jjd = {}
jjd.Async = function(p) {
	if( p === $_ ) return;
	this.set = false;
	this._bond_update = new List();
}
jjd.Async.__name__ = ["jjd","Async"];
jjd.Async.toAsync = function(v) {
	return new jjd.Async();
}
jjd.Async.wait = function(f,a) {
	var ret = new jjd.Async();
	var bnd = new jjd.Bond(f,a,ret);
	a.addBond(bnd);
	bnd.update();
	return ret;
}
jjd.Async.bind = function(f,a) {
	var ret = new jjd.Async();
	var bnd = new jjd.Bond(f,a,ret);
	a.addBond(bnd);
	bnd.update();
	return bnd;
}
jjd.Async.prototype.val = null;
jjd.Async.prototype.set = null;
jjd.Async.prototype._val = null;
jjd.Async.prototype._bond_update = null;
jjd.Async.prototype.yield = function(val) {
	this.set = true;
	this._val = val;
	var $it0 = this._bond_update.iterator();
	while( $it0.hasNext() ) {
		var b = $it0.next();
		b.update();
	}
}
jjd.Async.prototype._checkval = function() {
	if(!this.set) throw "Error: Value access on an unset Async variable."; else return this._val;
}
jjd.Async.prototype.addBond = function(bnd) {
	this._bond_update.add(bnd);
}
jjd.Async.prototype.removeBond = function(bnd) {
	return this._bond_update.remove(bnd);
}
jjd.Async.prototype.clearBonds = function() {
	this._bond_update = new List();
}
jjd.Async.prototype.__class__ = jjd.Async;
jjd.Async2 = function() { }
jjd.Async2.__name__ = ["jjd","Async2"];
jjd.Async2.wait = function(f,a,b) {
	var ret = new jjd.Async();
	var bnd = new jjd.Bond2(f,a,b,ret);
	a.addBond(bnd);
	b.addBond(bnd);
	bnd.update();
	return ret;
}
jjd.Async2.bind = function(f,a,b) {
	var ret = new jjd.Async();
	var bnd = new jjd.Bond2(f,a,b,ret);
	a.addBond(bnd);
	b.addBond(bnd);
	bnd.update();
	return bnd;
}
jjd.Async2.prototype.__class__ = jjd.Async2;
jjd.Async3 = function() { }
jjd.Async3.__name__ = ["jjd","Async3"];
jjd.Async3.wait = function(f,a,b,c) {
	var ret = new jjd.Async();
	var bnd = new jjd.Bond3(f,a,b,c,ret);
	a.addBond(bnd);
	b.addBond(bnd);
	c.addBond(bnd);
	bnd.update();
	return ret;
}
jjd.Async3.bind = function(f,a,b,c) {
	var ret = new jjd.Async();
	var bnd = new jjd.Bond3(f,a,b,c,ret);
	a.addBond(bnd);
	b.addBond(bnd);
	c.addBond(bnd);
	bnd.update();
	return bnd;
}
jjd.Async3.prototype.__class__ = jjd.Async3;
if(typeof haxe=='undefined') haxe = {}
haxe.Log = function() { }
haxe.Log.__name__ = ["haxe","Log"];
haxe.Log.trace = function(v,infos) {
	js.Boot.__trace(v,infos);
}
haxe.Log.clear = function() {
	js.Boot.__clear_trace();
}
haxe.Log.prototype.__class__ = haxe.Log;
Std = function() { }
Std.__name__ = ["Std"];
Std["is"] = function(v,t) {
	return js.Boot.__instanceof(v,t);
}
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
}
Std["int"] = function(x) {
	if(x < 0) return Math.ceil(x);
	return Math.floor(x);
}
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && x.charCodeAt(1) == 120) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
}
Std.parseFloat = function(x) {
	return parseFloat(x);
}
Std.random = function(x) {
	return Math.floor(Math.random() * x);
}
Std.prototype.__class__ = Std;
Demo = function() { }
Demo.__name__ = ["Demo"];
Demo.main = function() {
	var as_int = new jjd.Async();
	var delay = function() {
		as_int.yield(5);
	};
	var haxetimer = haxe.Timer.delay(delay,5000);
	var other_int = jjd.Async.wait(function(x) {
		haxe.Log.trace("I saw: " + x + ", added one to it, and passed it on",{ fileName : "Demo.hx", lineNumber : 11, className : "Demo", methodName : "main"});
		return x + 1;
	},as_int);
	var b_int = jjd.Async.bind(function(x) {
		haxe.Log.trace("I saw: " + x,{ fileName : "Demo.hx", lineNumber : 16, className : "Demo", methodName : "main"});
	},other_int);
	b_int.halt();
	var multi_arg_bond = jjd.Async2.bind(function(x,y) {
		haxe.Log.trace("x: " + Std.string(x),{ fileName : "Demo.hx", lineNumber : 22, className : "Demo", methodName : "main"});
		haxe.Log.trace("y: " + Std.string(y),{ fileName : "Demo.hx", lineNumber : 23, className : "Demo", methodName : "main"});
	},jjd.Async.toAsync(4),jjd.Async.toAsync(4));
}
Demo.prototype.__class__ = Demo;
haxe.Timer = function(time_ms) {
	if( time_ms === $_ ) return;
	this.id = haxe.Timer.arr.length;
	haxe.Timer.arr[this.id] = this;
	this.timerId = window.setInterval("haxe.Timer.arr[" + this.id + "].run();",time_ms);
}
haxe.Timer.__name__ = ["haxe","Timer"];
haxe.Timer.delay = function(f,time_ms) {
	var t = new haxe.Timer(time_ms);
	t.run = function() {
		t.stop();
		f();
	};
	return t;
}
haxe.Timer.measure = function(f,pos) {
	var t0 = haxe.Timer.stamp();
	var r = f();
	haxe.Log.trace(haxe.Timer.stamp() - t0 + "s",pos);
	return r;
}
haxe.Timer.stamp = function() {
	return Date.now().getTime() / 1000;
}
haxe.Timer.prototype.id = null;
haxe.Timer.prototype.timerId = null;
haxe.Timer.prototype.stop = function() {
	if(this.id == null) return;
	window.clearInterval(this.timerId);
	haxe.Timer.arr[this.id] = null;
	if(this.id > 100 && this.id == haxe.Timer.arr.length - 1) {
		var p = this.id - 1;
		while(p >= 0 && haxe.Timer.arr[p] == null) p--;
		haxe.Timer.arr = haxe.Timer.arr.slice(0,p + 1);
	}
	this.id = null;
}
haxe.Timer.prototype.run = function() {
}
haxe.Timer.prototype.__class__ = haxe.Timer;
List = function(p) {
	if( p === $_ ) return;
	this.length = 0;
}
List.__name__ = ["List"];
List.prototype.h = null;
List.prototype.q = null;
List.prototype.length = null;
List.prototype.add = function(item) {
	var x = [item];
	if(this.h == null) this.h = x; else this.q[1] = x;
	this.q = x;
	this.length++;
}
List.prototype.push = function(item) {
	var x = [item,this.h];
	this.h = x;
	if(this.q == null) this.q = x;
	this.length++;
}
List.prototype.first = function() {
	return this.h == null?null:this.h[0];
}
List.prototype.last = function() {
	return this.q == null?null:this.q[0];
}
List.prototype.pop = function() {
	if(this.h == null) return null;
	var x = this.h[0];
	this.h = this.h[1];
	if(this.h == null) this.q = null;
	this.length--;
	return x;
}
List.prototype.isEmpty = function() {
	return this.h == null;
}
List.prototype.clear = function() {
	this.h = null;
	this.q = null;
	this.length = 0;
}
List.prototype.remove = function(v) {
	var prev = null;
	var l = this.h;
	while(l != null) {
		if(l[0] == v) {
			if(prev == null) this.h = l[1]; else prev[1] = l[1];
			if(this.q == l) this.q = prev;
			this.length--;
			return true;
		}
		prev = l;
		l = l[1];
	}
	return false;
}
List.prototype.iterator = function() {
	return { h : this.h, hasNext : function() {
		return this.h != null;
	}, next : function() {
		if(this.h == null) return null;
		var x = this.h[0];
		this.h = this.h[1];
		return x;
	}};
}
List.prototype.toString = function() {
	var s = new StringBuf();
	var first = true;
	var l = this.h;
	s.b[s.b.length] = "{";
	while(l != null) {
		if(first) first = false; else s.b[s.b.length] = ", ";
		s.b[s.b.length] = Std.string(l[0]);
		l = l[1];
	}
	s.b[s.b.length] = "}";
	return s.b.join("");
}
List.prototype.join = function(sep) {
	var s = new StringBuf();
	var first = true;
	var l = this.h;
	while(l != null) {
		if(first) first = false; else s.b[s.b.length] = sep;
		s.b[s.b.length] = l[0];
		l = l[1];
	}
	return s.b.join("");
}
List.prototype.filter = function(f) {
	var l2 = new List();
	var l = this.h;
	while(l != null) {
		var v = l[0];
		l = l[1];
		if(f(v)) l2.add(v);
	}
	return l2;
}
List.prototype.map = function(f) {
	var b = new List();
	var l = this.h;
	while(l != null) {
		var v = l[0];
		l = l[1];
		b.add(f(v));
	}
	return b;
}
List.prototype.__class__ = List;
StringBuf = function(p) {
	if( p === $_ ) return;
	this.b = new Array();
}
StringBuf.__name__ = ["StringBuf"];
StringBuf.prototype.add = function(x) {
	this.b[this.b.length] = x;
}
StringBuf.prototype.addSub = function(s,pos,len) {
	this.b[this.b.length] = s.substr(pos,len);
}
StringBuf.prototype.addChar = function(c) {
	this.b[this.b.length] = String.fromCharCode(c);
}
StringBuf.prototype.toString = function() {
	return this.b.join("");
}
StringBuf.prototype.b = null;
StringBuf.prototype.__class__ = StringBuf;
jjd.IBond = function() { }
jjd.IBond.__name__ = ["jjd","IBond"];
jjd.IBond.prototype.update = null;
jjd.IBond.prototype.halt = null;
jjd.IBond.prototype.resume = null;
jjd.IBond.prototype.__class__ = jjd.IBond;
jjd.Bond = function(f,a,b) {
	if( f === $_ ) return;
	this.f = f;
	this.a = a;
	this.b = b;
	this._halt = false;
}
jjd.Bond.__name__ = ["jjd","Bond"];
jjd.Bond.containsFunction = function(b,f) {
	return b.f = f;
}
jjd.Bond.allSet = function($as) {
	var _g = 0;
	while(_g < $as.length) {
		var a = $as[_g];
		++_g;
		if(!a.set) return false;
	}
	return true;
}
jjd.Bond.prototype.f = null;
jjd.Bond.prototype.a = null;
jjd.Bond.prototype.b = null;
jjd.Bond.prototype._halt = null;
jjd.Bond.prototype.update = function() {
	if(this.a.set && !this._halt) this.b.yield(this.f(this.a._checkval()));
}
jjd.Bond.prototype.halt = function() {
	this._halt = true;
}
jjd.Bond.prototype.resume = function() {
	this._halt = false;
}
jjd.Bond.prototype.__class__ = jjd.Bond;
jjd.Bond.__interfaces__ = [jjd.IBond];
jjd.Bond2 = function(f,a,b,c) {
	if( f === $_ ) return;
	this.f = f;
	this.a = a;
	this.b = b;
	this.c = c;
	this._halt = false;
}
jjd.Bond2.__name__ = ["jjd","Bond2"];
jjd.Bond2.prototype.f = null;
jjd.Bond2.prototype.a = null;
jjd.Bond2.prototype.b = null;
jjd.Bond2.prototype.c = null;
jjd.Bond2.prototype._halt = null;
jjd.Bond2.prototype.halt = function() {
	this._halt = true;
}
jjd.Bond2.prototype.resume = function() {
	this._halt = false;
}
jjd.Bond2.prototype.update = function() {
	if(!this._halt && jjd.Bond.allSet([this.a,this.b])) this.c.yield(this.f(this.a._checkval(),this.b._checkval()));
}
jjd.Bond2.prototype.__class__ = jjd.Bond2;
jjd.Bond2.__interfaces__ = [jjd.IBond];
jjd.Bond3 = function(f,a,b,c,d) {
	if( f === $_ ) return;
	this.f = f;
	this.a = a;
	this.b = b;
	this.c = c;
	this.d = d;
	this._halt = false;
}
jjd.Bond3.__name__ = ["jjd","Bond3"];
jjd.Bond3.prototype.f = null;
jjd.Bond3.prototype.a = null;
jjd.Bond3.prototype.b = null;
jjd.Bond3.prototype.c = null;
jjd.Bond3.prototype.d = null;
jjd.Bond3.prototype._halt = null;
jjd.Bond3.prototype.halt = function() {
	this._halt = true;
}
jjd.Bond3.prototype.resume = function() {
	this._halt = false;
}
jjd.Bond3.prototype.update = function() {
	if(!this._halt && jjd.Bond.allSet([this.a,this.b,this.c])) this.d.yield(this.f(this.a._checkval(),this.b._checkval(),this.c._checkval()));
}
jjd.Bond3.prototype.__class__ = jjd.Bond3;
jjd.Bond3.__interfaces__ = [jjd.IBond];
IntIter = function(min,max) {
	if( min === $_ ) return;
	this.min = min;
	this.max = max;
}
IntIter.__name__ = ["IntIter"];
IntIter.prototype.min = null;
IntIter.prototype.max = null;
IntIter.prototype.hasNext = function() {
	return this.min < this.max;
}
IntIter.prototype.next = function() {
	return this.min++;
}
IntIter.prototype.__class__ = IntIter;
$_ = {}
js.Boot.__res = {}
js.Boot.__init();
{
	var d = Date;
	d.now = function() {
		return new Date();
	};
	d.fromTime = function(t) {
		var d1 = new Date();
		d1["setTime"](t);
		return d1;
	};
	d.fromString = function(s) {
		switch(s.length) {
		case 8:
			var k = s.split(":");
			var d1 = new Date();
			d1["setTime"](0);
			d1["setUTCHours"](k[0]);
			d1["setUTCMinutes"](k[1]);
			d1["setUTCSeconds"](k[2]);
			return d1;
		case 10:
			var k = s.split("-");
			return new Date(k[0],k[1] - 1,k[2],0,0,0);
		case 19:
			var k = s.split(" ");
			var y = k[0].split("-");
			var t = k[1].split(":");
			return new Date(y[0],y[1] - 1,y[2],t[0],t[1],t[2]);
		default:
			throw "Invalid date format : " + s;
		}
	};
	d.prototype["toString"] = function() {
		var date = this;
		var m = date.getMonth() + 1;
		var d1 = date.getDate();
		var h = date.getHours();
		var mi = date.getMinutes();
		var s = date.getSeconds();
		return date.getFullYear() + "-" + (m < 10?"0" + m:"" + m) + "-" + (d1 < 10?"0" + d1:"" + d1) + " " + (h < 10?"0" + h:"" + h) + ":" + (mi < 10?"0" + mi:"" + mi) + ":" + (s < 10?"0" + s:"" + s);
	};
	d.prototype.__class__ = d;
	d.__name__ = ["Date"];
}
{
	js.Lib.document = document;
	js.Lib.window = window;
	onerror = function(msg,url,line) {
		var f = js.Lib.onerror;
		if( f == null )
			return false;
		return f(msg,[url+":"+line]);
	}
}
{
	String.prototype.__class__ = String;
	String.__name__ = ["String"];
	Array.prototype.__class__ = Array;
	Array.__name__ = ["Array"];
	Int = { __name__ : ["Int"]};
	Dynamic = { __name__ : ["Dynamic"]};
	Float = Number;
	Float.__name__ = ["Float"];
	Bool = { __ename__ : ["Bool"]};
	Class = { __name__ : ["Class"]};
	Enum = { };
	Void = { __ename__ : ["Void"]};
}
{
	Math.__name__ = ["Math"];
	Math.NaN = Number["NaN"];
	Math.NEGATIVE_INFINITY = Number["NEGATIVE_INFINITY"];
	Math.POSITIVE_INFINITY = Number["POSITIVE_INFINITY"];
	Math.isFinite = function(i) {
		return isFinite(i);
	};
	Math.isNaN = function(i) {
		return isNaN(i);
	};
}
js.Lib.onerror = null;
haxe.Timer.arr = new Array();
Demo.main()