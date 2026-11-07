-- AlterTable
ALTER TABLE "outlets" ADD COLUMN     "receiptFooter" TEXT NOT NULL DEFAULT '',
ADD COLUMN     "receiptHeader" TEXT NOT NULL DEFAULT '';
