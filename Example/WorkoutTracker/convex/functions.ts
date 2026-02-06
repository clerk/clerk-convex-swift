import { mutation, query, QueryCtx } from "./_generated/server";
import {
  customQuery,
  customCtx,
  customMutation,
} from "convex-helpers/server/customFunctions";

async function userCheck(ctx: QueryCtx) {
  const identity = await ctx.auth.getUserIdentity();
  if (identity === null) {
    throw new Error("Unauthenticated call to create");
  }
  return { identity };
}

// Use `userQuery` instead of `query` to add this behavior.
export const userQuery = customQuery(
  query,
  customCtx(async (ctx) => {
    // Look up the logged in user
    return await userCheck(ctx);
  })
);

export const userMutation = customMutation(
  mutation,
  customCtx(async (ctx) => {
    return await userCheck(ctx);
  })
);
