module("luci.controller.release_ram",package.seeall)

function index()
	entry({"admin","release_ram"}, call("release_ram"), _("Release Ram"), 89)
	entry({"admin", "reboot"}, call("index_reboot"), _("Reboot"), 90)
end
function release_ram()
	luci.sys.call("sync && echo 3 > /proc/sys/vm/drop_caches")
	luci.http.redirect(luci.dispatcher.build_url("admin/status"))
end
function index_reboot()
	luci.http.redirect(luci.dispatcher.build_url("admin/system/reboot"))
end
