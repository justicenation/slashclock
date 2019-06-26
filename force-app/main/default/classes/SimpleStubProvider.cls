public without sharing virtual class SimpleStubProvider
implements System.StubProvider {

    public static List<MethodCall> calls = new List<MethodCall>();

    protected virtual Object getReturnValue(MethodCall call) {
        return null;
    }

    protected virtual Boolean hasReturnValue(MethodCall call) {
        return true;
    }

    public Object handleMethodCall(
        Object stubbedObject,
        String stubbedMethodName,
        System.Type returnType,
        List<System.Type> listOfParamTypes,
        List<String> listOfParamNames,
        List<Object> listOfArgs
    ) {
        
        // Construct the method call
        MethodCall call = new MethodCall(
            stubbedObject,
            stubbedMethodName,
            returnType,
            listOfParamTypes,
            listOfParamNames,
            listOfArgs
        );

        // Log the method call
        calls.add(call);
        
        // Return the default response or a custom response if one is specified
        return this.hasReturnValue(call) ? this.getReturnValue(call) : null;
    }

    private class MethodCall {
        public List<Object> args { get; set; }
        public List<String> paramNames { get; set; }
        public List<Type> paramTypes { get; set; }
        public Type returnType { get; set; }
        public Object stubbedObject { get; set; }
        public String stubbedMethodName { get; set; }

        public MethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            System.Type returnType,
            List<System.Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            this.stubbedObject = stubbedObject;
            this.stubbedMethodName = stubbedMethodName;
            this.returnType = returnType;
            this.paramTypes = listOfParamTypes;
            this.paramNames = listOfParamNames;
            this.args = listOfArgs;
        }
    }
}