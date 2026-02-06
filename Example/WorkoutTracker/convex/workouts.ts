import { v } from "convex/values";
import { userMutation, userQuery } from "./functions";

export const store = userMutation({
  args: {
    date: v.string(),
    duration: v.optional(v.int64()),
    activity: v.union(
      v.literal("Running"),
      v.literal("Lifting"),
      v.literal("Walking"),
      v.literal("Swimming")
    ),
  },
  handler: async (ctx, args) => {
    const newWorkoutId = await ctx.db.insert("workouts", {
      userId: ctx.identity.tokenIdentifier,
      date: args.date,
      duration: args.duration,
      activity: args.activity,
    });
    return newWorkoutId;
  },
});

export const getInRange = userQuery({
  args: {
    startDate: v.string(),
    endDate: v.string(),
  },
  handler: async (ctx, args) => {
    const workouts = await ctx.db
      .query("workouts")
      .withIndex("userId_date", (q) =>
        q
          .eq("userId", ctx.identity.tokenIdentifier)
          .gte("date", args.startDate)
          .lte("date", args.endDate)
      )
      .collect();
    return workouts;
  },
});
