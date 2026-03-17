---
marp: true
paginate: true
size: 16:9
---

# FITM Cloud (Special Project)
## Draft presentation (Marp)

**Team / Authors:** _(fill)_  
**Advisor:** _(fill)_  
**Date:** _(fill)_

<!--
Speaker notes (script):
- สวัสดีครับ/ค่ะ วันนี้จะนำเสนอ Special Project: FITM Cloud แพลตฟอร์มสำหรับบริหารจัดสรรเครื่องเสมือนเพื่อการเรียนการสอน
- โครงสร้างระบบเป็น Microservices โดยมี Midori (Frontend), Momoi (API), Yuzu (Worker), และ Yuuka (Deployment/Infra)
- การนำเสนอจะแบ่งเป็น 9 หัวข้อ ตามลำดับตั้งแต่ที่มา เป้าหมาย ขอบเขต วิธีใช้งาน ผลการดำเนินงาน วิเคราะห์ปัญหา แนวทางแก้ และข้อเสนอแนะ
-->

---

# Agenda
1. Origin and Significance
2. Purpose of the Special Project
3. Scope of the Special Project
4. How to Operate
5. Operating Results
6. Analysis and Conclusion
7. Problems and Obstacles
8. How to Solve the Problem
9. Suggestions

<!--
Speaker notes (script):
- วันนี้จะไล่ตามหัวข้อทั้ง 9 ส่วนนี้
- ระหว่างทางจะยกตัวอย่าง workflow จริง: student ส่ง request → instructor อนุมัติ → ระบบ provision → ผู้ใช้เชื่อมต่อด้วย SSH
-->

---

# 1) Origin and Significance
- Need a **self-service VM platform** for courses/labs
- Reduce manual provisioning by staff
- Provide **consistent, auditable workflow** (request → approve → provision)
- Support observability for reliability in real use

<!--
Speaker notes (script):
- จุดเริ่มต้นคือความต้องการเครื่องสำหรับแลป/โปรเจกต์ที่ต้องการสภาพแวดล้อมเหมือนกันและจัดการง่าย
- ถ้าเป็น manual จะช้าและผิดพลาดง่าย ไม่มี log หรือขั้นตอนอนุมัติที่ชัดเจน
- แพลตฟอร์มจึงต้องให้ผู้ใช้ทำเองได้ แต่ยังคุม policy และตรวจสอบย้อนหลังได้
-->

---

# 2) The Purpose of the Special Project
- Build a platform that:
  - manages **authentication + roles** (Student / Instructor / Admin)
  - provides **REST API** for platform operations
  - provisions VMs asynchronously via **queue + worker**
  - keeps **single source of truth** in database

<!--
Speaker notes (script):
- เป้าหมายหลักคือทำระบบครบวงจรตั้งแต่ login จนถึง VM ใช้งานได้
- ต้องมี role-based access: นักศึกษา/ผู้สอน/ผู้ดูแลระบบ
- งานที่ใช้เวลานาน เช่น provision ให้ทำแบบ async ผ่าน queue เพื่อไม่ให้ API ช้า
- สถานะต่าง ๆ ต้องอ่านจากฐานข้อมูลเป็นหลัก เพื่อความสอดคล้อง
-->

---

# 3) Scope of the Special Project
**In scope**
- Web dashboard (Midori)
- API service (Momoi)
- Worker for VM lifecycle (Yuzu)
- Deployment/infra set (Yuuka): DB, Redis, Object Storage, observability

**Out of scope (example)**
- Full multi-cloud support
- Advanced billing/chargeback

<!--
Speaker notes (script):
- ขอบเขตแบ่งชัดตาม service
- Midori คือหน้า dashboard, Momoi คือศูนย์กลางข้อมูลและตรรกะ, Yuzu คือคนทำงานหนักกับ Proxmox
- Yuuka รวมไฟล์ deploy และ supporting services เช่น PostgreSQL/Redis/Object storage/ระบบมอนิเตอร์
- บางเรื่องเช่น multi-cloud หรือระบบ billing เป็นงานในอนาคต
-->

---

# 4) How to Operate
**Quick start (typical flow)**
- Login at `/login`
- Check role: `Dashboard > Settings`
- Add SSH key: `Settings > SSH Keys`
- Student: `Requests > New Request` → submit
- After approval + provision: `Instances` → use IP to SSH

<!--
Speaker notes (script):
- วิธีใช้งานเริ่มจาก login
- ทุกคนควรเพิ่ม SSH key ก่อน เพราะใช้ SSH เป็นหลัก
- นักศึกษาส่งคำขอสร้าง instance ผ่านเมนู Requests
- เมื่อผู้สอนอนุมัติและระบบ provision เสร็จ จะเห็น instance ในหน้า Instances พร้อม IP/Hostname
- จากนั้นใช้งานด้วย SSH ตามคู่มือ
-->

---

# 5) Operating Results
- Role-based dashboards for **Student / Instructor / Admin**
- Request lifecycle:
  - `Pending` → `Approved` / `Rejected` → provisioned instance
- Instances view:
  - status, IP/hostname, audit logs
- Async execution:
  - queue-backed provisioning improves responsiveness

<!--
Speaker notes (script):
- ผลลัพธ์คือระบบทำงานครบ workflow
- มีสถานะคำร้องที่สื่อสารชัดเจน (pending/approved/rejected/cancelled)
- เมื่อ provision แล้ว ผู้ใช้ดูข้อมูลเชื่อมต่อและประวัติการเปลี่ยนแปลงได้
- API และ UI ไม่ต้องรอการสร้าง VM เพราะส่งเข้า queue แล้วให้ worker ทำต่อ
-->

---

# 6) Analysis and Conclusion
- Microservices separation:
  - UI (Midori) ↔ API (Momoi) ↔ Queue (Redis/BullMQ) ↔ Worker (Yuzu)
- Key design choices:
  - asynchronous jobs + retries
  - minimal queue payload (use IDs)
  - auditability via logs + DB records

<!--
Speaker notes (script):
- สรุปสถาปัตยกรรมคือแยกบทบาทชัด ทำให้ดูแลง่ายและ scale ได้
- ใช้ queue เพื่อรองรับงานยาว และออกแบบ payload ให้เก็บแค่ id เพื่อกันข้อมูลล้าสมัย
- การบันทึก audit log ช่วยให้ตรวจสอบย้อนหลังได้ ทั้งด้านคำร้องและ instance
-->

---

# 7) Problems and Obstacles
- Long-running VM operations
  - risk of timeouts if handled synchronously
- Data consistency
  - stale state between UI/API/worker
- Operational issues
  - retries, partial failures, and observability needs

<!--
Speaker notes (script):
- ปัญหาหลักคือการสร้าง/ลบ/เปลี่ยนสถานะ VM ใช้เวลานาน ถ้าทำแบบ sync จะ timeout
- อีกปัญหาคือสถานะอาจไม่ตรงกัน ถ้าแต่ละส่วนเก็บข้อมูลซ้ำ
- งาน infra มี partial failure ได้ ต้องมี retry และต้องมองเห็นสถานะผ่าน metrics/logs/traces
-->

---

# 8) How to Solve the Problem
- Use queue for async tasks
  - Momoi enqueues jobs
  - Yuzu executes and updates DB
- Ensure safe retry (idempotency-oriented)
  - worker re-reads latest state from DB
- Add audit logs + status tracking
  - user can see progress and history

<!--
Speaker notes (script):
- แนวทางแก้คือแยกงานหนักไปอยู่ queue
- Momoi ทำหน้าที่รับคำสั่งและส่ง job เข้า BullMQ ส่วน Yuzu ทำงานกับ Proxmox
- ให้ worker อ่านข้อมูลล่าสุดจาก DB ก่อนลงมือ เพื่อให้ retry ปลอดภัยและลดความเสี่ยงทำซ้ำผิด
- บันทึกสถานะและ audit log เพื่อให้ผู้ใช้และผู้ดูแลติดตามได้
-->

---

# 9) Suggestions
- Improve UX around async status
  - clearer progress + error messages
- Expand policies
  - quotas per course / user, templates governance
- Strengthen observability
  - dashboards, alerts, SLOs
- More automation
  - lifecycle cleanup, scheduled deprovision

<!--
Speaker notes (script):
- ข้อเสนอแนะคือทำ UX ให้ผู้ใช้เข้าใจสถานะงาน async มากขึ้น เช่น progress และ error ที่อ่านง่าย
- เพิ่ม policy เช่น quota ต่อรายวิชา/ผู้ใช้ และการกำกับ template
- ทำ observability ให้ครบ: dashboard/alert/SLO
- เพิ่ม automation เช่น cleanup เครื่องหมดอายุหรือ deprovision ตามกำหนด
-->

---

# Q & A

<!--
Speaker notes (script):
- ขอบคุณครับ/ค่ะ ยินดีตอบคำถาม
-->
