import React from "react";
import {NavLink} from 'react-router-dom';

export default function Navbar() {
    return (
        <div>
            <NavLink to={'/home'}>
                Home
            </NavLink>
            <NavLink to={'/private'}>
                Private Content
            </NavLink>
        </div>
    )
}