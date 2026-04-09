/*
  Warnings:

  - You are about to drop the column `isCurrent` on the `semester` table. All the data in the column will be lost.

*/
-- DropIndex
DROP INDEX "course_code_isActive_idx";

-- DropIndex
DROP INDEX "request_requesterId_courseOfferingId_key";

-- DropIndex
DROP INDEX "semester_isCurrent_idx";

-- AlterTable
ALTER TABLE "course" ADD COLUMN     "isProjectBased" BOOLEAN NOT NULL DEFAULT false;

-- AlterTable
ALTER TABLE "semester" DROP COLUMN "isCurrent";

-- CreateIndex
CREATE INDEX "course_code_isActive_isProjectBased_idx" ON "course"("code", "isActive", "isProjectBased");
