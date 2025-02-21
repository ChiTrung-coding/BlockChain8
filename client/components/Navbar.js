import {useState} from 'react'
import Link from "next/link";
import { useSelector } from 'react-redux';
import { useRouter } from 'next/router';

const Navbar = () => {

    const router = useRouter()
    const [openMenu,setOpenMenu] = useState(false);
    const account = useSelector(state=>state.web3Reducer.account)

  return (
    <div>
       
        <nav className="bg-[#F7F5F2]">
        <div className="max-w-7xl mx-auto px-2 sm:px-6 lg:px-8">
            <div className="relative flex items-center justify-between h-16">
            <div className="flex-1 flex items-center justify-center sm:items-stretch sm:justify-start">
                <div className="flex-shrink-0 flex items-center">
                      <h4 className='font-mono text-xl text-greay font-bold hidden lg:block'>QUY CONG DONG</h4>
                </div>
                <div className="hidden sm:block sm:ml-6">
                <div className="flex space-x-4">
                    <Link href="/dashboard"  ><span className={`${router.pathname === "/dashboard"?"bg-[#F7C984]":""} text-greay px-3 py-2 rounded-md text-sm font-medium hover:cursor-pointer hover:bg-[#F7C984] hover:text-greay`}>Dashboard</span></Link>
                    <Link href="/my-contributions"><span className={`${router.pathname === "/my-contributions"?"bg-[#F7C984]":""} text-greay px-3 py-2 rounded-md text-sm font-medium hover:cursor-pointer hover:bg-[#F7C984] hover:text-greay`}>My contribution</span></Link>
                </div>
                </div>
            </div>
            <div className="absolute inset-y-0 right-0 flex items-center pr-2 sm:static sm:inset-auto sm:ml-6 sm:pr-0">
                <button type="button" className="p-1 w-40 truncate rounded-full text-greay hover:text-greay ">
                  <span >{account}</span>
                </button>
            </div>
            </div>
        </div>
        </nav>

    </div>
  )
}

export default Navbar