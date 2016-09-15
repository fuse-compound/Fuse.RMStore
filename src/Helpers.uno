using Uno;
using Uno.UX;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;
using Fuse;
using Fuse.Triggers;
using Fuse.Controls;
using Fuse.Controls.Native;
using Fuse.Controls.Native.Android;
using Fuse.Scripting;
using Fuse.Reactive;

namespace Fuse.URMStore
{
    internal static class Helpers
    {

        //----------------------------------------------------------------------
        // Uno/Foreign Helpers

        [Foreign(Language.ObjC)]
        extern(iOS)
        static ObjC.Object NewSet ()
        @{
            return [[NSMutableSet alloc] init];
        @}

        [Foreign(Language.ObjC)]
        extern(iOS)
        static void AddToSet (ObjC.Object s, string item)
        @{
            [s addObject:item];
        @}

        extern(iOS)
        public static ObjC.Object ToNSSet(IEnumerable<string> e)
        {
            ObjC.Object s = NewSet();

            foreach (var x in e)
                AddToSet(s, x);

            return s;
        }

        [Foreign(Language.ObjC)]
        extern(iOS)
        public static List<ObjC.Object> NSArrayToList(ObjC.Object nsarr)
        @{
            id<UnoObject> res = @{List<ObjC.Object>():New()};
            for (id obj in nsarr) {
                @{List<ObjC.Object>:Of(res).Add(ObjC.Object):Call(obj)};
            }
            return res;
        @}

        extern(iOS)
        public static List<T> MapNSArray<T>(Func<ObjC.Object,T> func, ObjC.Object nsarr)
        {
            var res = new List<T>();
            foreach (var o in (NSArrayToList(nsarr)))
                res.Add(func(o));
            return res;
        }

        [Foreign(Language.ObjC)]
        extern(iOS)
        public static string NSObjectToString(ObjC.Object obj)
        @{
            return (NSString*)obj;
        @}


        [Foreign(Language.ObjC)]
        extern(iOS)
        static ObjC.Object NewISOFormatter()
        @{
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
            return dateFormatter;
        @}

        extern(iOS) static ObjC.Object _dateFormatter = null;
        extern(iOS) static ObjC.Object GetISOFormatter()
        {
            if (_dateFormatter == null)
                _dateFormatter = NewISOFormatter();
            return _dateFormatter;
        }

        [Foreign(Language.ObjC)]
        extern(iOS)
        public static string NSDateToUTCISO(ObjC.Object dt)
        @{
            NSDateFormatter* dateFormatter = (NSDateFormatter*)@{GetISOFormatter():Call()};
            NSDate* dateTime = (NSDate*)dt;
            return [dateFormatter stringFromDate:dateTime];
        @}

        [Foreign(Language.ObjC)]
        extern(iOS)
        static ObjC.Object NewPriceFormatter()
        @{
            NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            return numberFormatter;
        @}

        extern(iOS) static ObjC.Object _priceFormatter = null;
        extern(iOS) static ObjC.Object GetPriceFormatter()
        {
            if (_priceFormatter == null)
                _priceFormatter = NewPriceFormatter();
            return _priceFormatter;
        }

        [Foreign(Language.ObjC)]
        extern(iOS)
        public static string FormatDecimalAsPrice(ObjC.Object decimalNumber, ObjC.Object locale)
        @{
            NSNumberFormatter* priceFormatter = (NSNumberFormatter*)@{GetPriceFormatter():Call()};
            NSLocale* priceLocale = (NSLocale*)locale;
            NSDecimalNumber* price = (NSDecimalNumber*)decimalNumber;

            [priceFormatter setLocale:priceLocale];
            return [priceFormatter stringFromNumber:price];
        @}

        //----------------------------------------------------------------------
        // JS Helpers

        extern(iOS)
        public static Scripting.Array MapToJS<T>(Context c, Func<Context, T,object> func, IList<T> data)
        {
            if (func==null) return ToJSArr(c, data);
            var arr = (Scripting.Array)c.Evaluate("(no file)", "new Array(" + data.Count + ")");
            for (int i = 0; i < data.Count; i++)
                arr[i] = func(c, data[i]);
            return arr;
        }

        extern(iOS)
        public static Scripting.Array ToJSArr<T>(Context c, IList<T> data)
        {
            var arr = (Scripting.Array)c.Evaluate("(no file)", "new Array(" + data.Count + ")");
            for (int i = 0; i < data.Count; i++)
                arr[i] = data[i];
            return arr;
        }
    }
}
