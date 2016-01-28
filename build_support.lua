local lfs = require "lfs"
function go_build()
    if autoupdate == true then
        local cwd = lfs.currentdir()
        lfs.chdir("toolchains/elua")
        os.execute("rm -f romfs/*")
        os.execute("git pull")
        lfs.chdir(cwd)
        lfs.chdir("toolchains/stormport")
        os.execute("git pull")
        lfs.chdir(cwd)
    end
    if reflash_kernel == true then
        local cwd = lfs.currentdir()
        lfs.chdir("toolchains/stormport/apps/Kernel")
        local pfx = ""
        if kernel_opts.quiet == true then
           pfx = pfx .. "KERNEL_QUIET_MODE=TRUE "
        end
        if kernel_opts.eth_shield == true then
            pfx = pfx .. "KERNEL_WITH_ETH_SHIELD=TRUE"
        end
        print("executing make")
        if bulk_flash == true then
            os.execute(string.format("%s make storm installall", pfx))
        else
            os.execute(string.format("%s make storm install", pfx))
        end
        lfs.chdir(cwd)
    end
    os.execute("rm -f toolchains/elua/romfs/*")
    if autorun ~= nil then
        if lfs.attributes(autorun) == nil then
            print ("could not load autorun file")
            return
        end
        lfs.link(string.format("%s/%s",lfs.currentdir(),autorun), "toolchains/elua/romfs/autorun.lua", true)
    end
    for k,v in pairs(libs) do
        if lfs.attributes(v) == nil then
            print (string.format("could not load library '%s'",k))
            return
        end
        lfs.link(string.format("%s/%s",lfs.currentdir(),v),string.format("toolchains/elua/romfs/%s.lua",k), true)
    end
    lfs.chdir("toolchains/elua")
    if bulk_flash == true then
        os.execute("./gobuildall")
    else
        os.execute("./gobuild")
    end
end
