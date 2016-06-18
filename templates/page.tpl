<ignore>
  Developers documentation goes here
</ignore>

<apply template="default">
  <bind tag="longname">Einstein, Feynman, Heisenberg, and Newton Research Corporation Ltd.<sup>TM</sup></bind>
  <bind tag="copyright-class">bold</bind>
  <bind tag="copyright">
    <p class="${copyright-class}">Copyright (c) Andrew Slabko, E-mail: andrew@slabko.com</p>
  </bind>

  <apply template="navigation"/>
  <foo>
     <p>
       We at <longname/> have research expertise in many areas of physics.
       Employment at <longname/> carries significant prestige.  The rigorous
       hiring process developed by <longname/> is leading the industry.
    </p>
  </foo>
  <h3>Names:</h3>
  <ul>
    <names>
      <li><name/></li>
    </names>
  </ul>
  <link/>
  <copyright/>
  <markdown>
## Big name
And we also have `some` code
  </markdown>
</apply>
