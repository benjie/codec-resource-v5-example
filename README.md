Demonstrates how to add a codec + resource to PostGraphile so that you can
represent an arbitrary SQL expression as if it were any other table in your
schema.

To use:

```bash
createdb harry
psql -X1v ON_ERROR_STOP=1 -f schema.sql harry
yarn start
```

See the plugin in `graphile.config.mjs` for details of adding the codec and
resource.

Then issue a query such as:

```graphql
{
  allBlogPosts {
    nodes {
      ctName
      entryId
      fieldName
      stringValue
      booleanValue
    }
  }
}
```

to see the data from your new "virtual table".
