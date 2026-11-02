
const $ = id => document.getElementById(id);

async function api(url, options = {}) {
    const response = await fetch(url, {
        headers: { "Content-Type": "application/json" },
        ...options
    });

    const data = await response.json();

    if (!response.ok) {
        throw new Error(data.error || "Something went wrong");
    }

    return data;
}

function notify(message) {
    $("notice").textContent = message;
}

function showPage(page) {
    document.querySelectorAll(".page").forEach(section => {
        section.classList.remove("active");
    });

    $(page).classList.add("active");

    const titles = {
        dashboard: "Dashboard Overview",
        slots: "Parking Slots",
        reservations: "Reservations",
        entryexit: "Vehicle Entry and Exit",
        payments: "Payments",
        audit: "Audit Logs"
    };

    $("page-title").textContent = titles[page];

    if (page === "slots") loadSlots();
    if (page === "reservations") {
        loadOptions();
        loadReservations();
    }
    if (page === "entryexit") loadRecords();
    if (page === "payments") loadPayments();
    if (page === "audit") loadAudit();
}

function badge(status) {
    return `<span class="status status-${status}">${status}</span>`;
}

function dateText(value) {
    return value ? String(value).replace("T", " ").slice(0, 16) : "—";
}

function slotHTML(slot) {
    const status = slot.slot_status.toLowerCase();
    const icon = slot.slot_type === "BIKE" ? "🏍️" :
        slot.slot_type === "EV" ? "⚡" : "🚗";

    return `
        <div class="slot-tile ${status}">
            <div>${icon}</div>
            <strong>${slot.slot_number}</strong>
            <small>${slot.slot_type}</small>
            <small>${slot.slot_status}</small>
        </div>
    `;
}

// Dashboard
async function loadDashboard() {
    const data = await api("/api/dashboard");

    $("total-slots").textContent = data.total_slots;
    $("available-slots").textContent = data.available_slots;
    $("occupied-slots").textContent = data.occupied_slots;
    $("active-reservations").textContent = data.active_reservations;
    $("revenue").textContent = Number(data.revenue).toFixed(2);

    const slots = await api("/api/slots");

    $("slot-preview").innerHTML =
        slots.slice(0, 8).map(slotHTML).join("");

    const reservations = await api("/api/reservations");

    $("recent-reservations").innerHTML =
        reservations.slice(0, 5).map(r => `
            <tr>
                <td>${r.reservation_id}</td>
                <td>${r.full_name}</td>
                <td>${r.vehicle_number}</td>
                <td>${r.slot_number}</td>
                <td>${dateText(r.start_time)}</td>
                <td>${badge(r.booking_status)}</td>
            </tr>
        `).join("");
}

// Slots
async function loadSlots() {
    const slots = await api("/api/slots");

    $("all-slots").innerHTML =
        slots.map(slotHTML).join("");
}

// Booking options
async function loadOptions() {
    const data = await api("/api/options");

    $("user_id").innerHTML =
        '<option value="">Select customer</option>' +
        data.users.map(u =>
            `<option value="${u.user_id}">${u.full_name}</option>`
        ).join("");

    $("vehicle_id").innerHTML =
        '<option value="">Select vehicle</option>' +
        data.vehicles.map(v =>
            `<option value="${v.vehicle_id}" data-user="${v.user_id}" data-type="${v.vehicle_type}">
                ${v.vehicle_number} (${v.vehicle_type})
            </option>`
        ).join("");

    $("slot_id").innerHTML =
        '<option value="">Select slot</option>' +
        data.slots.map(s =>
            `<option value="${s.slot_id}" data-type="${s.slot_type}">
                ${s.slot_number} (${s.slot_type})
            </option>`
        ).join("");

    updateBookingOptions();
}

function updateBookingOptions() {
    const userId = $("user_id").value;
    const vehicleSelect = $("vehicle_id");

    Array.from(vehicleSelect.options).forEach(option => {
        if (!option.value) return;
        option.hidden = userId && option.dataset.user !== userId;
    });

    updateSlotOptions();
}

function updateSlotOptions() {
    const vehicleOption = $("vehicle_id").selectedOptions[0];
    const vehicleType = vehicleOption ? vehicleOption.dataset.type : "";

    Array.from($("slot_id").options).forEach(option => {
        if (!option.value) return;
        option.hidden = vehicleType && option.dataset.type !== vehicleType;
    });
}

$("user_id").addEventListener("change", updateBookingOptions);
$("vehicle_id").addEventListener("change", updateSlotOptions);

// Create reservation
$("booking-form").addEventListener("submit", async event => {
    event.preventDefault();

    const data = {
        user_id: $("user_id").value,
        vehicle_id: $("vehicle_id").value,
        slot_id: $("slot_id").value,
        start_time: $("start_time").value,
        end_time: $("end_time").value
    };

    if (new Date(data.end_time) <= new Date(data.start_time)) {
        notify("End time must be after start time.");
        return;
    }

    try {
        const result = await api("/api/book", {
            method: "POST",
            body: JSON.stringify(data)
        });

        notify(result.message);
        $("booking-form").reset();
        await refreshAll();
        showPage("reservations");

    } catch (error) {
        notify(error.message);
    }
});

// Reservations
async function loadReservations() {
    const rows = await api("/api/reservations");

    $("reservations-table").innerHTML = rows.map(r => `
        <tr>
            <td>${r.reservation_id}</td>
            <td>${r.full_name}</td>
            <td>${r.vehicle_number}</td>
            <td>${r.slot_number}</td>
            <td>${dateText(r.start_time)}</td>
            <td>${dateText(r.end_time)}</td>
            <td>${badge(r.booking_status)}</td>
            <td>
                ${r.booking_status === "BOOKED" ?
            `<button class="action-button danger"
                onclick="cancelReservation(${r.reservation_id})">
                Cancel</button>` : "—"}
            </td>
        </tr>
    `).join("");
}

async function cancelReservation(id) {
    if (!confirm("Cancel this reservation?")) return;

    try {
        const result = await api("/api/cancel", {
            method: "POST",
            body: JSON.stringify({ reservation_id: id })
        });

        notify(result.message);
        await refreshAll();
    } catch (error) {
        notify(error.message);
    }
}

// Entry and exit records
async function loadRecords() {
    const rows = await api("/api/records");

    $("records-table").innerHTML = rows.map(r => {
        let action = "—";

        if (!r.entry_time) {
            action = `<button class="action-button"
                onclick="recordEntry(${r.reservation_id})">
                Record Entry</button>`;
        } else if (!r.exit_time) {
            action = `<button class="action-button"
                onclick="recordExit(${r.record_id})">
                Record Exit</button>`;
        }

        return `
            <tr>
                <td>${r.record_id}</td>
                <td>${r.reservation_id}</td>
                <td>${r.full_name}</td>
                <td>${r.vehicle_number}</td>
                <td>${r.slot_number}</td>
                <td>${dateText(r.entry_time)}</td>
                <td>${dateText(r.exit_time)}</td>
                <td>${r.duration_hours}</td>
                <td>₹${Number(r.parking_fee).toFixed(2)}</td>
                <td>${action}</td>
            </tr>
        `;
    }).join("");
}

async function recordEntry(id) {
    try {
        const result = await api("/api/entry", {
            method: "POST",
            body: JSON.stringify({ reservation_id: id })
        });

        notify(result.message);
        await refreshAll();
    } catch (error) {
        notify(error.message);
    }
}

async function recordExit(id) {
    if (!confirm("Record vehicle exit?")) return;

    try {
        const result = await api("/api/exit", {
            method: "POST",
            body: JSON.stringify({ record_id: id })
        });

        notify(result.message);
        await refreshAll();
    } catch (error) {
        notify(error.message);
    }
}

// Payments
async function loadPayments() {
    const rows = await api("/api/payments");

    $("payments-table").innerHTML = rows.map(p => `
        <tr>
            <td>${p.payment_id}</td>
            <td>${p.record_id}</td>
            <td>${p.vehicle_number}</td>
            <td>${p.slot_number}</td>
            <td>₹${Number(p.amount).toFixed(2)}</td>
            <td>${badge(p.payment_status)}</td>
            <td>${dateText(p.payment_date)}</td>
            <td>
                ${p.payment_status === "PENDING" ?
            `<button class="action-button"
                onclick="confirmPayment(${p.payment_id})">
                Mark Paid</button>` : "—"}
            </td>
        </tr>
    `).join("");
}

async function confirmPayment(id) {
    try {
        const result = await api("/api/payments/confirm", {
            method: "POST",
            body: JSON.stringify({ payment_id: id })
        });

        notify(result.message);
        await refreshAll();
    } catch (error) {
        notify(error.message);
    }
}

// Audit logs
async function loadAudit() {
    const rows = await api("/api/audit");

    $("audit-table").innerHTML = rows.map(a => `
        <tr>
            <td>${a.log_id}</td>
            <td>${a.slot_number || "—"}</td>
            <td>${badge(a.old_status || "—")}</td>
            <td>${badge(a.new_status || "—")}</td>
            <td>${dateText(a.change_date)}</td>
            <td>${a.changed_by}</td>
        </tr>
    `).join("");
}

// Refresh all dashboard data
async function refreshAll() {
    try {
        await loadDashboard();
        await loadSlots();
        await loadReservations();
        await loadRecords();
        await loadPayments();
        await loadAudit();
    } catch (error) {
        notify(error.message);
    }
}

refreshAll();
