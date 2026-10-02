-- AlterTable
ALTER TABLE "members" ADD COLUMN     "church" TEXT,
ADD COLUMN     "district" TEXT,
ADD COLUMN     "field" TEXT,
ADD COLUMN     "joinedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "postName" TEXT;

-- CreateIndex
CREATE INDEX "members_field_idx" ON "members"("field");

-- CreateIndex
CREATE INDEX "members_district_idx" ON "members"("district");

-- CreateIndex
CREATE INDEX "members_church_idx" ON "members"("church");
