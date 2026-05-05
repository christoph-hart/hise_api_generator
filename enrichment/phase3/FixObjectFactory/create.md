Calling this method will create a single object with the supplied data layout. The returned object is **NOT** a JSON object, but a custom object type with these properties:

- predefined, typed and preallocated properties based on the JSON prototype of the factory
- no methods, just data

However from a workflow perspective, it behaves just like a JSON object:

- you can access (read & write) properties using the dot operator: `obj.key = value` and `value = obj.key`
- you can even call `trace()` to create a string representation that looks like it's JSON equivalent (useful for debugging)

You can of course put these objects into a JS array or JSON object, however it's highly recommended to use one of the special data containers instead. If you do so, you will most likely need to create a single object alongside the data container and then use this as "interface object" for shuffling data in and out of the container:

