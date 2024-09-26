// @ts-check
import "postgraphile";
import { sql } from "postgraphile/pg-sql2";
import { recordCodec, TYPES } from "postgraphile/@dataplan/pg";
import { makePgService } from "postgraphile/adaptors/pg";
import { PostGraphileAmberPreset } from "postgraphile/presets/amber";
import { gatherConfig } from "postgraphile/graphile-build";

/** @type {GraphileConfig.Plugin} */
const BlogPostPlugin = {
  name: "BlogPostPlugin",
  version: "0.0.0",

  gather: gatherConfig({
    /**
     * @returns {{ blogPostCodec: import("postgraphile/@dataplan/pg").PgCodec | null }}
     */
    initialState() {
      return {
        blogPostCodec: null,
      };
    },
    hooks: {
      pgRegistry_PgRegistryBuilder_pgCodecs(event, info) {
        event.state.blogPostCodec = recordCodec({
          name: "blog_post",
          executor: event.helpers.pgIntrospection.getExecutorForService("main"),
          identifier: sql`record`,
          attributes: {
            ct_name: {
              codec: TYPES.text,
              notNull: true,
            },
            entry_id: {
              codec: TYPES.text,
              notNull: true,
            },
            field_name: {
              codec: TYPES.text,
              notNull: true,
            },
            string_value: {
              codec: TYPES.text,
              notNull: false,
            },
            boolean_value: {
              codec: TYPES.boolean,
              notNull: false,
            },
            number_value: {
              codec: TYPES.float,
              notNull: false,
            },
          },
        });
        info.registryBuilder.addCodec(event.state.blogPostCodec);
      },
      pgRegistry_PgRegistryBuilder_pgResources(event, info) {
        const { blogPostCodec } = event.state;
        if (!blogPostCodec) {
          throw new Error(`Codec wasn't created!`);
        }
        info.registryBuilder.addResource({
          codec: blogPostCodec,
          from: sql`
            (
              SELECT
                ct.name as ct_name,
                e.id as entry_id,
                f.name as field_name,
                fv.string_value,
                fv.boolean_value, fv.number_value
              FROM app_public.entries e
              JOIN app_public.content_types ct ON e.content_type_id = ct.id
              LEFT JOIN app_public.field_values fv ON e.id = fv.entry_id
              LEFT JOIN app_public.fields f ON fv.field_id = f.id
            )
          `,
          name: "blog_posts",
          executor: event.helpers.pgIntrospection.getExecutorForService("main"),
          uniques: [
            // TODO: add a primary key, e.g.
            /*
            {
              attributes: ["ct_name", "entry_id"],
              isPrimary: true,
            },
            */
          ],
        });
      },
    },
  }),
};

/** @type {GraphileConfig.Preset} */
const preset = {
  extends: [PostGraphileAmberPreset],
  plugins: [BlogPostPlugin],
  pgServices: [
    makePgService({
      connectionString: "postgres:///harry",
      schemas: ["app_public"],
    }),
  ],
};

export default preset;
