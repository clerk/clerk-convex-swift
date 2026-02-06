import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  workouts: defineTable({
    activity: v.string(),
    date: v.string(), // Must be in format "YYYY-MM-DD" a.k.a ISO 8601 format
    duration: v.optional(v.int64()),
    userId: v.string(),
  }).index("userId_date", ["userId", "date"]),
});
