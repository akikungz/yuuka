CREATE OR REPLACE FUNCTION sync_pve_network_ip_allocation()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP IN ('UPDATE', 'DELETE') AND OLD."pveNetworkIPId" IS NOT NULL THEN
    UPDATE "pve_network_ip"
    SET "isAllocated" = EXISTS (
      SELECT 1
      FROM "pve_vm"
      WHERE "pveNetworkIPId" = OLD."pveNetworkIPId"
        AND id <> OLD.id
    )
    WHERE id = OLD."pveNetworkIPId";
  END IF;

  IF TG_OP IN ('INSERT', 'UPDATE') AND NEW."pveNetworkIPId" IS NOT NULL THEN
    UPDATE "pve_network_ip"
    SET "isAllocated" = TRUE
    WHERE id = NEW."pveNetworkIPId";
  END IF;

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS sync_pve_network_ip_allocation_trigger ON "pve_vm";

CREATE TRIGGER sync_pve_network_ip_allocation_trigger
AFTER INSERT OR UPDATE OR DELETE ON "pve_vm"
FOR EACH ROW
EXECUTE FUNCTION sync_pve_network_ip_allocation();

UPDATE "pve_network_ip" ip
SET "isAllocated" = EXISTS (
  SELECT 1
  FROM "pve_vm" vm
  WHERE vm."pveNetworkIPId" = ip.id
);
